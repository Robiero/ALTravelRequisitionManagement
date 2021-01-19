Page 50060 "Employee Grade"
{
    DeleteAllowed = false;
    PageType = List;
    SourceTable = "Employee Travel Grade";
    UsageCategory = Lists;


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
                field(CurrencyCode; "Currency Code")
                {
                    ApplicationArea = Basic;
                }
                field(HotelRating; "Hotel Rating")
                {
                    ApplicationArea = Basic;
                }
                field(MaxRoomAmtAllowable; "Max. Room Amt. Allowable")
                {
                    ApplicationArea = Basic;
                }
                field(MealsAmount; "Meals Amount")
                {
                    ApplicationArea = Basic;
                }
                field(TransportAmount; "Transport Amount")
                {
                    ApplicationArea = Basic;
                }
                field(OutofPocket; "Out of Pocket")
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

