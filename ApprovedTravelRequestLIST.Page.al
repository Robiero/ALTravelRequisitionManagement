Page 50045 "Approved Travel Request LIST"
{
    CardPageID = "Approved Travel Request";
    DeleteAllowed = false;
    PageType = List;
    UsageCategory = Lists;
    ApplicationArea = Suite;
    SourceTable = "Travel Request Header";
    SourceTableView = where("Approval Status" = filter(Approved),
                            Type = filter(Travel),
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
                field(EmployeeNo; "Employee No.")
                {
                    ApplicationArea = Basic;
                }
                field(EmployeeName; "Employee Name")
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
            }
        }
        area(factboxes)
        {
            systempart(Control9; Notes)
            {
            }
            systempart(Control10; MyNotes)
            {
            }
            systempart(Control11; Links)
            {
            }
        }
    }

    actions
    {
        area(reporting)
        {
            action("Travel Authorization Detailed Report")
            {
                ApplicationArea = Basic;
                Image = "Report";
                Promoted = true;
                PromotedCategory = "Report";
                RunObject = Report "Travel AuthorizationDetailRept";
            }
        }
    }
}

