Page 50061 "Approval Matrix"
{
    PageType = List;
    UsageCategory = Lists;
    ApplicationArea = Suite;
    SourceTable = "Approval Matrix";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(ApproverID; "Approver ID")
                {
                    ApplicationArea = Basic;
                }
                field(Branch; Branch)
                {
                    ApplicationArea = Basic;
                }
                field(UserStatus; "User Status")
                {
                    ApplicationArea = Basic;
                }
                field(TravelApprover; "Travel Approver")
                {
                    ApplicationArea = Basic;
                }
                field(TravelHRApprover; "Travel HR Approver")
                {
                    ApplicationArea = Basic;
                }
            }
        }
    }

    actions
    {
    }
}

