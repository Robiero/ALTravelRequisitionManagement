Table 50060 "Employee Travel Grade"
{

    fields
    {
        field(1; "Code"; Code[10])
        {
            DataClassification = ToBeClassified;
        }
        field(2; "Currency Code"; Code[10])
        {
            DataClassification = ToBeClassified;
            TableRelation = Currency;
        }
        field(3; "Hotel Rating"; Option)
        {
            DataClassification = ToBeClassified;
            OptionCaption = ' ,3 Star,4 Star,5 Star';
            OptionMembers = " ","3 Star","4 Star","5 Star";
        }
        field(4; "Max. Room Amt. Allowable"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(5; "Meals Amount"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(6; "Transport Amount"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(7; "Out of Pocket"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
    }

    keys
    {
        key(Key1; "Code", "Currency Code")
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
    }
}

