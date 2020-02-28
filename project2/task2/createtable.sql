use master
if exists(select * from sys.databases where name='db2') 
	drop database db2
create database db2
go
use db2
create table Ord(
Order_num int primary key,
Trans_id varchar(10),
Operation_type varchar(10) check(Operation_type in ('read','write')),
Data_item varchar(10),
)
go
create type GraphType as table (Prior_Tran varchar(10), Posterior_Tran varchar(10))
go
create proc DetactCycle(@Graph as GraphType READONLY)
as
begin
	-- 递归过程
    with PriorGraph(Prior_Tran, Posterior_Tran) as
	(select Prior_Tran,Posterior_Tran
	from 	@Graph
	union all
	select	A.Prior_Tran, B.Posterior_Tran
	from	@Graph A, PriorGraph B
	where	A.Posterior_Tran = B.Prior_Tran and A.Prior_Tran <> B.Posterior_Tran
	 and not exists
	 (select *
	 from @Graph C
	 where C.Prior_Tran = A.Prior_Tran and C.Posterior_Tran = B.Posterior_Tran
	 )
	)
	select *
	into #PriorGraph
	from PriorGraph

	-- 根据是否有起点和终点相同的路径来判断是否有圈
	if( exists( 
		select *
		from #PriorGraph G1, #PriorGraph G2
		where G1.Prior_Tran = G2.Posterior_Tran and G1.Posterior_Tran = G2.Prior_Tran
		)
		)
		return 1
	return 0
end
go
create proc ConflictSer
as
begin
	declare @ConflictGraph GraphType

	--构建冲突图
	insert into @ConflictGraph
	select distinct O1.Trans_id, O2.Trans_id
	from Ord O1, Ord O2
	where O1.Order_num>O2.Order_num and O1.Trans_id <> O2.Trans_id 
			and O1.Data_item = O2.Data_item 
			and not(O1.Operation_type = 'read' and O2.Operation_type = 'read')

	select N'下一张表:冲突可串行化判定图';
	select * from @ConflictGraph;

	declare @result int
	-- 执行判圈过程
	exec @result = DetactCycle @ConflictGraph
	return @result
end
go
create proc ViewSer
as
begin
	-- 创建初始图， Read_Tran读取From_Tran写入的Data_item
	with ViewGraphInit(From_Tran, Read_Tran, Data_item) as
	(select distinct O1.Trans_id, O2.Trans_id, O1.Data_item
	from Ord O1, Ord O2
	where O1.Operation_type = 'write' and O2.Operation_type = 'read' and O1.Order_num < O2.Order_num
		and O1.Trans_id <> O2.Trans_id and O1.Data_item = O2.Data_item
		and (not exists( select *
			from Ord O3
			where O3.Operation_type = 'write' and O3.Order_num > O1.Order_num 
				and O3.Order_num < O2.Order_num and O3.Data_item = O1.Data_item
				))
	union 
	select 'Tb', O2.Trans_id, O2.Data_item
	from Ord O2
	where O2.Operation_type = 'read' 
		and not exists( select *
			from Ord O3
			where O3.Operation_type = 'read' and O3.Order_num < O2.Order_num
				and O3.Data_item = O2.Data_item)
	union
	select O1.Trans_id, 'Te', O1.Data_item
	from Ord O1
	where O1.Operation_type = 'write' 
		and not exists( select *
			from Ord O3
			where O3.Operation_type = 'write' and O3.Order_num > O1.Order_num
				and O3.Data_item = O1.Data_item)
	)
	select *
	into #ViewGraphInit
	from ViewGraphInit

	select *
	into #ViewGraphSecond
	from #ViewGraphInit
	;
	
	-- 用与构建有标号的边的中间表
	select row_number() over (ORDER BY G1.From_Tran) as Edge_Label,G1.From_Tran as Prior_Tran,G1.Read_Tran as Posterior_Tran,O1.Trans_id as Other_Tran
	into #ViewGraphFinalPart3
	from #ViewGraphInit G1, Ord O1
	where G1.From_Tran<>'Tb' and G1.Read_Tran<>'Te'
		and O1.Operation_type = 'write' and O1.Trans_id<>G1.From_Tran
		and O1.Trans_id<>G1.Read_Tran and O1.Data_item = G1.Data_item
	;

	-- 构建视图可串行化判定图
	with ViewGraphFinal(Edge_Label,Prior_Tran,Posterior_Tran) as
	(select 0,From_Tran,Read_Tran
	from #ViewGraphSecond
	union 
	select 0,G1.Read_Tran,O1.Trans_id
	from #ViewGraphSecond G1, Ord O1
	where G1.From_Tran = 'Tb' and O1.Operation_type = 'write' 
		and O1.Data_item = G1.Data_item and G1.Read_Tran <> O1.Trans_id
	union 
	select 0,O1.Trans_id, G1.From_Tran
	from #ViewGraphInit G1, Ord O1
	where G1.Read_Tran = 'Te' and O1.Operation_type = 'write'
		and G1.Data_item = O1.Data_item and O1.Trans_id<> G1.From_Tran
	union
	select Edge_Label,Other_Tran,Prior_Tran
	from #ViewGraphFinalPart3
	union
	select Edge_Label,Posterior_Tran,Other_Tran
	from #ViewGraphFinalPart3
	)
	select * 
	into #ViewGraph
	from ViewGraphFinal
	;

	-- 标号>0的边加入可选择边表
	select Edge_Label,Prior_Tran,Posterior_Tran,
			rank() over (partition by Edge_Label order by Prior_Tran) as tag
	into #OptionGraph
	from #ViewGraph
	where Edge_Label > 0

	-- 表示组合的码
	declare @total_comb int
	declare @total_label int
	set @total_label = (select max(Edge_Label) from #OptionGraph)
	set @total_comb = power(2,@total_label)

	select N'下一张表:视图可串行化判定图';
	select * from #ViewGraph;
	--select * from #OptionGraph

	-- 枚举所有组合
	declare @i int
	declare @succeed int
	set @i = 0
	set @succeed = 0
	while( @i < @total_comb )
	begin
		declare @TestGraph GraphType;

		-- 将0边插入测试图
		insert into @TestGraph
		select Prior_Tran, Posterior_Tran
		from #ViewGraph
		where Edge_Label = 0

		-- 按照前面选定的组合将有标号的边插入测试图
		declare @j int, @k int
		set @j = 1
		set @k =@i
		while @j <= @total_label
		begin
			declare @c int
			set @c = @k % 2
			set @k = @k / 2
			insert into @TestGraph
				select Prior_Tran, Posterior_Tran
				from #OptionGraph
				where Edge_Label = @i
					and tag = @c + 1
			set @j += 1
		end
		set @i += 1;

		declare @TestGraphDistinct GraphType
		insert into @TestGraphDistinct
		select distinct * 
		from @TestGraph

		-- 调用基本图判圈过程
		declare @tmp int
		exec @tmp = DetactCycle @TestGraphDistinct;
		
		if( @tmp = 0)
		begin
			set @succeed = 1
		end

		delete from @TestGraph
		delete from @TestGraphDistinct
	end

	--返回
	if(@succeed = 0)
		return 1

	return 0
end