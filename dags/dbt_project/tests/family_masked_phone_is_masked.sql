select *
from {{ ref('family_masked') }}
where current_role() != 'ACCOUNTADMIN'
  and (office_phone not like 'XXX-XXX-%' or personal_phone not like 'XXX-XXX-%')