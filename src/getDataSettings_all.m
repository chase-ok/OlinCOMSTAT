function Data = getDataSettings_all()
% Data = getDataSettings()
% Returns a structure array that includes the specifications for our data runs.
%
%   Data should be a structure array with the following fields for each data
%   set:
%       - evironment: either 'aerobic' or 'anaerobic'
%       - type: either 'WT' or 'Flg-'
%       - innoculation: date in 'M.D' format; eg '4.27' for April 27th
%       - RunSettings: a cell array where each element is itelf a cell array
%             corresponding to data collected on a particular day for this
%             innoculation. Each of these elements has the following index
%             structure:
%                 (1) The time (in days) since innoculation
%                 (2) The folder the series is located in (by convention, should
%                     be formatted as the date ('M.D') on which it was taken.
%                 (3) A cell array of individual series settings with the
%                     following index structure:
%                         (1) The series number of the stack
%                         (2) The number of initial images to skip
%                         (3) The number of images to use for smacking
%   
%   The format used:
%       Data(n).environment  = 'aerobic' or 'anaerobic';
%       Data(n).type         = 'WT' or 'Flg-';
%       Data(n).innoculation = 'M.D';
%       Data(n).RunSettings  = { {time, folder, { {num, skip, smack} ... } }
%                                .
%                                .
%                                .
%                              }
%       ...
%
%   Usage:
%       DataSettings = getDataSettings()

    Data(1).environment  = Environment.Anaerobic;
    Data(1).type         = Type.WT;
    Data(1).innoculation = '1.17';
    Data(1).Days  = { {2, '1.19', { {34 2 0} } }, ...
                             ...
                             {4, '1.21', { {32 10 0} {47 3 0} } }, ...
                             ...
                             {8, '1.25', { {35 1 0} {37 0 0} {39 0 0} ...
                                           {43 0 0} {47 0 0} {49 0 0} ...
                                           {51 0 0} {54 0 0} {56 0 0} ...
                                           {95 17 0} {99 2 0} {101 5 0} ...
                                           {105 8 0} {132 0 0} {134 0 0} } } ...
                           };
    
    Data(2).environment  = Environment.Anaerobic;
    Data(2).type         =  Type.FlgMinus;
    Data(2).innoculation = '1.17';
    Data(2).Days  = { {2, '1.19', { {16 2 0} } }, ...
                             ...
                             {8, '1.25', { {63 0 0} {67 0 0} {75 0 0} ...
                                           {111 0 0} {113 0 0} {120 0 0} ...
                                           {122 0 0} {124 0 0} {128 0 0} ...
                                           {130 0 0} } }
                           };
                       
    Data(3).environment  = Environment.Aerobic;
    Data(3).type         = Type.WT;
    Data(3).innoculation = '2.25';
    Data(3).Days  = { {3, '2.28',  { {8 9 0} {23 3 0} } }, ...
                             ...
                             {5, '3.2',   { {42 3 0} {44 5 0} {46 5 0} ...
                                            {50 4 0} {52 5 0} {54 5 0} } }, ...
                             ...
                             {7, '3.4',   { {36 12 0} {38 0 0} {45 8 0} ...
                                            {47 6 0} {49 7 0} {51 10 0} } }, ...
                             ...
                             {10, '3.7',  { {36 5 0} } }, ...
                             ...
                             {14, '3.11', { {15 3 0} {17 3 0} {21 6 0} } }
                           };
                       
    Data(4).environment  = Environment.Aerobic;
    Data(4).type         =  Type.FlgMinus;
    Data(4).innoculation = '2.25';
    Data(4).Days  = { {3, '2.28',  { {17 5 0} {19 2 0} } }, ...
                             ...
                             {5. '3.2',   { {20 5 0} {26 4 0} {28 3 0} } }, ...
                             ...
                             {7, '3.4',   { {30 7 0} {32 0 0} {34 0 0} } }, ...
                             ...
                             {10, '3.7',  { {32 1 0} {34 2 0} } }, ...
                             ...
                             {14, '3.11', { {23 5 0} {25 3 0} {27 5 0} ...
                                            {29 3 0} {31 5 0} } }
                           };
                       
    Data(5).environment  = Environment.Aerobic;
    Data(5).type         = Type.WT;
    Data(5).innoculation = '3.29';
    Data(5).Days  = { {7, '4.5',  { {101 4 0} {103 2 0} {105 0 0} ...
                                           {110 9 0} {108 3 0} ...
                                           {112 5 0} } }, ...
                             ...
                             {10, '4.8', { {45 1 0} {47 0 0} {49 0 0} ...
                                           {51 0 0} {53 0 0} {55 0 0} ...
                                           {57 0 0} {59 0 0} } }
                           };
                       
    Data(6).environment  = Environment.Aerobic;
    Data(6).type         =   Type.FlgMinus;
    Data(6).innoculation = '3.29';
    Data(6).Days  = { {7, '4.5',  { {81 1 0} {82 0 0} {91 2 0} ...
                                           {95 2 0} {97 0 0} } }, ...
                             ...
                             {10, '4.8', { {26 18 0} {30 0 0} {32 0 0} ...
                                           {36 0 0} {39 22 0} {41 0 0} ...
                                           {43 0 0} } }
                            };
                        
    Data(7).environment  = Environment.Aerobic;
    Data(7).type         = Type.WT;
    Data(7).innoculation = '4.11';
    Data(7).Days  = { {2, '4.13', { {92 3 0} {94 5 0} {98 7 0} ...
                                           {101 4 0} {103 4 0} {105 4 0} ...
                                           {107 3 0} {109 6 0} ...
                                           {111 2 0} } }, ...
                             ...
                             {4, '4.15', { {58 4 0} {60 8 0} {62 4 0} ...
                                           {66 0 0} {68 2 0} } }
                           };
                       
    Data(8).environment  = Environment.Aerobic;
    Data(8).type         =  Type.FlgMinus;
    Data(8).innoculation = '5.5';
    Data(8).Days  = { {6, '5.11', { {20 35 0} {27 2 0} {29 2 0} ...
                                            } }
                           }; 
                       
    Data(9).environment  = Environment.Aerobic;
    Data(9).type         = Type.WT;
    Data(9).innoculation = '5.5';
    Data(9).Days  = { {4, '5.9', { {20 4 0} {22 2 0} {24 20 0} {26 1 0} ...
                                } }, ...
                             ...
                             {6, '5.11', { {8 35 0} {10 35 0} {12 30 0} {14 30 0} ...
                                            } }
                           };  
                       
    Data(10).environment  = Environment.Anaerobic;
    Data(10).type         = Type.WT;
    Data(10).innoculation = '5.5';
    Data(10).Days  = { {4, '5.9', { {34 14 0} {38 5 0} {40 5 0} ...
                                } }, ...
                             ...
                             {7, '5.12', { {17 0 0} {23 1 0} {25 1 0} {27 0 0} {29 1 0} ...
                                            } }
                           }; 
                       
    Data(11).environment  = Environment.Anaerobic;
    Data(11).type         =  Type.FlgMinus;
    Data(11).innoculation = '5.5';
    Data(11).Days  = { {4, '5.9', { {42 5 0} {55 0 0} {57 0 0} {59 1 0} ...
                                } }, ...
                             ...
                             {7, '5.12', { {3 65 0} {7 34 0} {9 28 0} {11 31 0} ...
                                 {13 32 0} {15 28 0} } }
                           };                    
end