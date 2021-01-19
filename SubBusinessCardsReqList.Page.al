Page 50079 "Sub Business Cards Req List"
{
    ApplicationArea = Basic;
    CardPageID = "Business Cards Request";
    DeleteAllowed = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = List;
    SourceTable = "Travel Request Header";
    SourceTableView = where(Type = filter("Business Card"),
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
                field(RaisedBy; "Raised By")
                {
                    ApplicationArea = Basic;
                }
                field(QtyRequested; "Qty Requested")
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
        area(reporting)
        {
            action("Approved Business Cards Report")
            {
                ApplicationArea = Basic;
                Promoted = true;
                PromotedCategory = "Report";
                PromotedIsBig = true;
                RunObject = Report "Approved Business Cards Report";
            }
        }
    }

    trigger OnNewRecord(BelowxRec: Boolean)
    var
        openitems: Boolean;
    begin
        Travelheader.SetCurrentkey("No.");
        Travelheader.SetRange(Type, Travelheader.Type::"Business Card");
        Travelheader.SetRange("Approval Status", Travelheader."approval status"::Open);
        Travelheader.SetRange("Raised By", UserId);
        if Travelheader.FindFirst then
            openitems := true;

        if openitems = true then Error('kindly utilize the open record on the page');
    end;

    var
        Travelheader: Record "Travel Request Header";
}

