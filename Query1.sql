
with [CTE] as
(
    select 
        *, 
        [Hierarchy] = convert(nvarchar(max), N':' + convert(nvarchar, [Id]) + N':'),HasCircularReference = Convert(bit,0) 
    from
        [dbo].[Person]
    where
        [ParentId] is null

    union all
    select
        [Child].*,
        [Hierarchy] = convert(nvarchar(max), [Parent].[Hierarchy] + convert(nvarchar, [Child].[Id]) + N':'),
		HasCircularReference = Convert(bit,
		  CASE
			  WHEN ':' + parent.Hierarchy + ':' LIKE
				 '%:' + Convert(varchar(100), child.Id) + ':%'
			  THEN 1
			  ELSE 0
		  END)
    from
        [dbo].[Person] [Child]
        inner join [CTE] [Parent] on [Child].[ParentID] = [Parent].[Id]
		where Parent.HasCircularReference = 0
)

select Id,ParentId,Hierarchy,HasCircularReference  from [CTE] order by [Hierarchy];