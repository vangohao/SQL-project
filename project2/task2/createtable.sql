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
	-- �ݹ����
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

	-- �����Ƿ��������յ���ͬ��·�����ж��Ƿ���Ȧ
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

	--������ͻͼ
	insert into @ConflictGraph
	select distinct O1.Trans_id, O2.Trans_id
	from Ord O1, Ord O2
	where O1.Order_num>O2.Order_num and O1.Trans_id <> O2.Trans_id 
			and O1.Data_item = O2.Data_item 
			and not(O1.Operation_type = 'read' and O2.Operation_type = 'read')

	select N'��һ�ű�:��ͻ�ɴ��л��ж�ͼ';
	select * from @ConflictGraph;

	declare @result int
	-- ִ����Ȧ����
	exec @result = DetactCycle @ConflictGraph
	return @result
end
go
create proc ViewSer
as
begin
	-- ������ʼͼ�� Read_Tran��ȡFrom_Tranд���Data_item
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
	
	-- ���빹���б�ŵıߵ��м��
	select row_number() over (ORDER BY G1.From_Tran) as Edge_Label,G1.From_Tran as Prior_Tran,G1.Read_Tran as Posterior_Tran,O1.Trans_id as Other_Tran
	into #ViewGraphFinalPart3
	from #ViewGraphInit G1, Ord O1
	where G1.From_Tran<>'Tb' and G1.Read_Tran<>'Te'
		and O1.Operation_type = 'write' and O1.Trans_id<>G1.From_Tran
		and O1.Trans_id<>G1.Read_Tran and O1.Data_item = G1.Data_item
	;

	-- ������ͼ�ɴ��л��ж�ͼ
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

	-- ���>0�ı߼����ѡ��߱�
	select Edge_Label,Prior_Tran,Posterior_Tran,
			rank() over (partition by Edge_Label order by Prior_Tran) as tag
	into #OptionGraph
	from #ViewGraph
	where Edge_Label > 0

	-- ��ʾ��ϵ���
	declare @total_comb int
	declare @total_label int
	set @total_label = (select max(Edge_Label) from #OptionGraph)
	set @total_comb = power(2,@total_label)

	select N'��һ�ű�:��ͼ�ɴ��л��ж�ͼ';
	select * from #ViewGraph;
	--select * from #OptionGraph

	-- ö���������
	declare @i int
	declare @succeed int
	set @i = 0
	set @succeed = 0
	while( @i < @total_comb )
	begin
		declare @TestGraph GraphType;

		-- ��0�߲������ͼ
		insert into @TestGraph
		select Prior_Tran, Posterior_Tran
		from #ViewGraph
		where Edge_Label = 0

		-- ����ǰ��ѡ������Ͻ��б�ŵı߲������ͼ
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

		-- ���û���ͼ��Ȧ����
		declare @tmp int
		exec @tmp = DetactCycle @TestGraphDistinct;
		
		if( @tmp = 0)
		begin
			set @succeed = 1
		end

		delete from @TestGraph
		delete from @TestGraphDistinct
	end

	--����
	if(@succeed = 0)
		return 1

	return 0
end