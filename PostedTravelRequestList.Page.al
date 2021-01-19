Page 50069 "Posted Travel Request List"
{
    CardPageID = "Posted Travel Request";
    DeleteAllowed = false;
    Editable = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = List;
    UsageCategory = History;
    ApplicationArea = Suite;
    SourceTable = "Posted Travel Request Header";

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

    trigger OnOpenPage()
    begin
        SetFilter("Raised By", UserId);
    end;
}

