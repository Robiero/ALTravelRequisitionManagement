Page 50075 "Stamps Request List"
{
    ApplicationArea = Basic;
    CardPageID = "Stamps Request";
    DeleteAllowed = false;
    Editable = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = List;
    SourceTable = "Travel Request Header";
    SourceTableView = where(Type = filter(Stamp),
                            Archived = filter(false));
    UsageCategory = Lists;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(No; "No.")
                {
                    ApplicationArea = Basic;
                }
                field(Department; Department)
                {
                    ApplicationArea = Basic;
                }
                field(EmployeeNo; "Employee No.")
                {
                    ApplicationArea = Basic;
                }
                field(EmployeeName; "Employee Name")
                {
                    ApplicationArea = Basic;
                }
                field(RaisedDate; "Raised Date")
                {
                    ApplicationArea = Basic;
                }
                field(ApprovalStatus; "Approval Status")
                {
                    ApplicationArea = Basic;
                }
            }
        }
    }

    actions
    {
    }

    trigger OnNewRecord(BelowxRec: Boolean)
    var
        openitems: Boolean;
    begin
        Travelheader.SetCurrentkey("No.");
        Travelheader.SetRange(Type, Travelheader.Type::Stamp);
        Travelheader.SetRange("Approval Status", Travelheader."approval status"::Open);
        Travelheader.SetRange("Raised By", UserId);
        if Travelheader.FindFirst then
            openitems := true;

        if openitems = true then Error('Kindly utilize the open record on the page');
    end;

    trigger OnOpenPage()
    begin
        SetFilter("Raised By", UserId);
    end;

    var
        Travelheader: Record "Travel Request Header";
}

