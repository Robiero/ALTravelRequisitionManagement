Page 50031 "Business Cards Req List Dpt"
{
    CardPageID = "Business Cards Request";
    DeleteAllowed = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = List;
    UsageCategory = Lists;
    ApplicationArea = Suite;
    SourceTable = "Travel Request Header";
    SourceTableView = where(Type = filter("Business Card"),
                            "Approval Status" = filter(<> Open));

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
    }

    trigger OnNewRecord(BelowxRec: Boolean)
    var
        openitems: Boolean;
    begin
        Travelheader.SetCurrentkey("No.");
        Travelheader.SetRange(Type, Travelheader.Type::"Business Card");
        Travelheader.SetRange("Approval Status", Travelheader."approval status"::Open);
        //Travelheader.SETRANGE("Raised By",USERID);
        if Travelheader.FindFirst then
            openitems := true;

        if openitems = true then Error('Not allowed to create new');
    end;

    trigger OnOpenPage()
    begin
        Usersetup.SetRange("User ID", UserId);
        if Usersetup.Find('-') then begin
            if Usersetup."Department Code" <> '' then begin
                SetRange(Department, Usersetup."Department Code");
            end
        end;
    end;

    var
        Travelheader: Record "Travel Request Header";
        Usersetup: Record "User Setup";
}

