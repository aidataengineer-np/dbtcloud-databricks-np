select
    payroll_id,
    gross_pay,
    bonus,
    tax,
    net_pay
from {{ ref('fact_payroll') }}
where net_pay < 0
   or gross_pay < 0
   or bonus < 0
   or tax < 0
   or net_pay > gross_pay + bonus
