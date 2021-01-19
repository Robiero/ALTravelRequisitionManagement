Page 50066 "Travel Request List"
{
    CardPageID = "Travel Request";
    DeleteAllowed = false;
    Editable = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = List;
    UsageCategory = Lists;
    ApplicationArea = Suite;
    SourceTable = "Travel Request Header";
    SourceTableView = where(Type = filter(Travel),
                            Archived = filter(false));

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
                field(HRApprovalStatus; "HR Approval Status")
                {
                    ApplicationArea = Basic;
                }
                field(TravelFrom; "Travel From")
                {
                    ApplicationArea = Basic;
                }
                field(TravelTo; "Travel To")
                {
                    ApplicationArea = Basic;
                }
                field(FromDate; "Travel From Date")
                {
                    ApplicationArea = Basic;
                    Caption = 'From Date';
                }
                field(ToDate; "Travel To Date")
                {
                    ApplicationArea = Basic;
                    Caption = 'To Date';
                }
                field(NoofDays; "No. of Days")
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
        TravelHeader.SetCurrentkey("No.");
        TravelHeader.SetRange(Type, TravelHeader.Type::Travel);
        TravelHeader.SetRange("Approval Status", TravelHeader."approval status"::Open);
        TravelHeader.SetRange("Raised By", UserId);
        if TravelHeader.FindFirst then
            openitems := true;

        if openitems = true then Error('Kindly utilize the open record on the page');
    end;

    trigger OnOpenPage()
    begin
        SetFilter("Raised By", UserId);
    end;

    var
        TravelHeader: Record "Travel Request Header";
}

