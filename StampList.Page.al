Page 50050 "Stamp List"
{
    DeleteAllowed = false;
    PageType = List;
    UsageCategory = Lists;
    ApplicationArea = Suite;
    SourceTable = "Stamp Listing";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Code"; Code)
                {
                    ApplicationArea = Basic;
                }
                field(Name; Name)
                {
                    ApplicationArea = Basic;
                }
            }
        }
        area(factboxes)
        {
            systempart(Control6; Outlook)
            {
            }
            systempart(Control7; Notes)
            {
            }
            systempart(Control8; MyNotes)
            {
            }
            systempart(Control9; Links)
            {
            }
        }
    }

    actions
    {
    }
}

