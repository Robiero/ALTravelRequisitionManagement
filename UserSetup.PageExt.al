PageExtension 50003 pageextension50003 extends "User Setup"
{
    Caption = 'User Setup';

    //Unsupported feature: Property Insertion (DeleteAllowed) on ""User Setup"(Page 119)".

    layout
    {
        modify("User ID")
        {
            ToolTip = 'Specifies the ID of the user who posted the entry, to be used, for example, in the change log.';
            /*   }
              modify("Allow Posting From")
              { */
            //ApplicationArea = Basic;

            //Unsupported feature: Property Modification (SourceExpr) on ""Allow Posting From"(Control 4)".


            //Unsupported feature: Property Modification (Name) on ""Allow Posting From"(Control 4)".

            /*  }
             modify("Allow Posting To")
             { */
            /*  ApplicationArea = Basic; */

            //Unsupported feature: Property Modification (SourceExpr) on ""Allow Posting To"(Control 6)".


            //Unsupported feature: Property Modification (Name) on ""Allow Posting To"(Control 6)".

            /* }
            modify("Register Time")
            { */
            //ApplicationArea = Basic;

            //Unsupported feature: Property Modification (SourceExpr) on ""Register Time"(Control 8)".


            //Unsupported feature: Property Modification (Name) on ""Register Time"(Control 8)".

        }
        modify("Salespers./Purch. Code")
        {
            ApplicationArea = Basic;

            //Unsupported feature: Property Modification (SourceExpr) on ""Salespers./Purch. Code"(Control 5)".


            //Unsupported feature: Property Modification (Name) on ""Salespers./Purch. Code"(Control 5)".

        }
        modify("Sales Resp. Ctr. Filter")
        {
            ApplicationArea = Basic;

            //Unsupported feature: Property Modification (SourceExpr) on ""Sales Resp. Ctr. Filter"(Control 15)".


            //Unsupported feature: Property Modification (Name) on ""Sales Resp. Ctr. Filter"(Control 15)".

        }
        modify("Purchase Resp. Ctr. Filter")
        {
            ApplicationArea = Basic;

            //Unsupported feature: Property Modification (SourceExpr) on ""Purchase Resp. Ctr. Filter"(Control 17)".


            //Unsupported feature: Property Modification (Name) on ""Purchase Resp. Ctr. Filter"(Control 17)".

        }
        modify("Service Resp. Ctr. Filter")
        {
            ApplicationArea = Basic;

            //Unsupported feature: Property Modification (SourceExpr) on ""Service Resp. Ctr. Filter"(Control 21)".


            //Unsupported feature: Property Modification (Name) on ""Service Resp. Ctr. Filter"(Control 21)".

        }
        modify("Time Sheet Admin.")
        {
            ApplicationArea = Basic;

            //Unsupported feature: Property Modification (SourceExpr) on ""Time Sheet Admin."(Control 3)".


            //Unsupported feature: Property Modification (Name) on ""Time Sheet Admin."(Control 3)".

        }
        modify(Email)
        {
            ToolTip = 'Specifies the user''s email address.';
        }

        //Unsupported feature: Property Deletion (ToolTipML) on ""Allow Posting From"(Control 4)".


        //Unsupported feature: Property Deletion (ToolTipML) on ""Allow Posting To"(Control 6)".


        //Unsupported feature: Property Deletion (ToolTipML) on ""Register Time"(Control 8)".


        //Unsupported feature: Property Deletion (ToolTipML) on ""Salespers./Purch. Code"(Control 5)".


        //Unsupported feature: Property Deletion (ToolTipML) on ""Sales Resp. Ctr. Filter"(Control 15)".


        //Unsupported feature: Property Deletion (ToolTipML) on ""Purchase Resp. Ctr. Filter"(Control 17)".


        //Unsupported feature: Property Deletion (ToolTipML) on ""Service Resp. Ctr. Filter"(Control 21)".


        //Unsupported feature: Property Deletion (ToolTipML) on ""Time Sheet Admin."(Control 3)".

        addafter("User ID")
        {
            /* field("Allow Posting From"; "Allow Posting From")
            {
                ApplicationArea = Basic;
            } */
            /* field("Allow Posting To"; "Allow Posting To")
            { */
            /*    ApplicationArea = Basic;
           } */
            field("Approval Administrator"; "Approval Administrator")
            {
                ApplicationArea = Basic;
            }
            field("Employee No."; "Employee No.")
            {
                ApplicationArea = Basic;
            }
            field("Full Name"; "Full Name")
            {
                ApplicationArea = Basic;
            }
            field(Branch; Branch)
            {
                ApplicationArea = Basic;
            }
            field("Department Code"; "Department Code")
            {
                ApplicationArea = Basic;
            }
            field(Location; Location)
            {
                ApplicationArea = Basic;
            }
        }
        addafter(Email)
        {
            field("Approver ID"; "Approver ID")
            {
                ApplicationArea = Basic;
            }
            field("HR Administrator"; "HR Administrator")
            {
                ApplicationArea = Basic;
            }
        }
        addafter("Allow Posting To")
        {
            field("Petty Cash Administrator"; "Petty Cash Administrator")
            {
                ApplicationArea = Basic;
            }
        }
        addafter("Time Sheet Admin.")
        {
            field("Vendor EFT Details Approver"; "Vendor EFT Details Approver")
            {
                ApplicationArea = Basic;
            }
            field("MD Approver"; "MD Approver")
            {
                ApplicationArea = Basic;
            }
            field("Head of Department"; "Head of Department")
            {
                ApplicationArea = Basic;
            }
            field("Head of Finance"; "Head of Finance")
            {
                ApplicationArea = Basic;
            }
            field(HOD; HOD)
            {
                ApplicationArea = Basic;
                Caption = 'HOD(By Dept Code)';
            }
            field("Overall HOD Branch"; "Overall HOD Branch")
            {
                ApplicationArea = Basic;
            }
        }
        addafter("Service Resp. Ctr. Filter")
        {
            field("Dept HRBP"; "Dept HRBP")
            {
                ApplicationArea = Basic;
                Caption = 'HRBP';
            }
        }
        addafter("Sales Resp. Ctr. Filter")
        {
            field("Approval Delegated"; "Approval Delegated")
            {
                ApplicationArea = Basic;
            }
        }
        addafter("Purchase Resp. Ctr. Filter")
        {
            field("Procurement Manager"; "Procurement Manager")
            {
                ApplicationArea = Basic;
            }
            field("PO Locking Permission"; "PO Locking Permission")
            {
                ApplicationArea = Basic;
            }
            field("Create Contract"; "Create Contract")
            {
                ApplicationArea = Basic;
            }
            field("Can Reassign Period"; "Can Reassign Period")
            {
                ApplicationArea = Basic;
            }
        }
        moveafter("User ID"; Email)
        moveafter(Email; "Allow Posting To")
        //moveafter("ICT Approver"; "Salespers./Purch. Code")
        // moveafter("Facility Approver"; "Time Sheet Admin.")
        //moveafter("Finance Approver"; "Service Resp. Ctr. Filter")
    }
}

