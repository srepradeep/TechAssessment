Declare @empId bigint;
set @empId = 2;

with [CTE] ([Id], [ParentID], [Path], [HasCircularReference])as
(
    select [Id],[ParentID],
         convert(nvarchar(max), N':' ),HasCircularReference = Convert(bit,0) 
    from
        [dbo].[Person]
    where
        Id = @empId

    union all

    select
        Child.[Id],Child.[ParentID],
        convert(nvarchar(max), [ParentCTE].[Path] + convert(nvarchar, [Child].[Id]) + N':'),
		HasCircularReference = Convert(bit,
		  CASE
			  WHEN ':' + ParentCTE.Path + ':' LIKE
				 '%:' + Convert(varchar(100), child.[Id]) + ':%'
			  THEN 1
			  ELSE 0
		  END)
    from
        [dbo].[Person] [Child]
        inner join [CTE] [ParentCTE] 
		on [Child].[ParentID] = [ParentCTE].[Id]
		where ParentCTE.HasCircularReference = 0
)
select * from [CTE] where id <> @empId and HasCircularReference=0
order by [Id];

