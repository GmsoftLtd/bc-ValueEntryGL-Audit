/// <summary>
/// Grants access to the Value Entry G/L Audit objects.
/// </summary>
permissionset 50100 "Value Entry Audit"
{
    Assignable = true;
    Caption = 'Value Entry G/L Audit';

    Permissions =
        report "Value Entry G/L Audit" = X,
        page "Value Entry G/L Audit List" = X,
        page "Value Entry Audit Setup" = X,
        page "Value Entry G/L Audit Results" = X,
        codeunit "Value Entry Audit Mgt." = X,
        codeunit "Value Entry Audit Job" = X,
        tabledata "Value Entry Audit Setup" = RIMD,
        tabledata "Value Entry Audit Result" = RIMD;
}
