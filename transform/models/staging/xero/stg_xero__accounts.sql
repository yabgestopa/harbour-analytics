with

source as (
    select * from {{ source('xero', 'account') }}
),

renamed as (
    select
        -- ids
        account_id,

        -- details
        code as account_code,
        name as account_name,
        type as account_type,
        class as account_class,
        status as account_status,
        description,
        system_account,
        tax_type,
        currency_code,
        reporting_code,
        reporting_code_name,
        bank_account_type,

        -- timestamps
        updated_date_utc as updated_at,
        _fivetran_synced as synced_at

    from source
)

select * from renamed