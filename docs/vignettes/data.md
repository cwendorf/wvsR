# [`wvsR`](https://github.com/cwendorf/wvsR/)

## Data Definitions

This page provides an overview of the data reference material in `wvsR`,
including country coverage, available survey items, and supported
cultural dimensions for the EVS/WVS joint dataset.

- [Identify Countries](#identify-countries)
- [Check Item Availability](#check-item-availability)
- [Cultural Dimensions](#cultural-dimensions)

------------------------------------------------------------------------

### Identify Countries

The `wvs_countries()` function lists the available countries and waves.
The `wave` argument filters the list to countries that participated in a
given wave.

``` r
wvs_countries()
```


    COUNTRY INFORMATION

       ISO          Country    N
    1   AD          Andorra 1004
    2   AL          Albania 1435
    3   AM          Armenia 2723
    4   AR        Argentina 1003
    5   AT          Austria 1644
    6   AU        Australia 1813
    7   AZ       Azerbaijan 1800
    8   BA           Bosnia 1724
    9   BD       Bangladesh 1200
    10  BG         Bulgaria 1558
    11  BO          Bolivia 2067
    12  BR           Brazil 1762
    13  BY          Belarus 1548
    14  CA           Canada 4018
    15  CH      Switzerland 3174
    16  CL            Chile 1000
    17  CN            China 3036
    18  CO         Colombia 1520
    19  CY           Cyprus 1000
    20  CZ   Czech Republic 3011
    21  DE          Germany 3698
    22  DK          Denmark 3362
    23  EC          Ecuador 1200
    24  EE          Estonia 1304
    25  EG            Egypt 1200
    26  ES            Spain 1209
    27  ET         Ethiopia 1230
    28  FI          Finland 1199
    29  FR           France 1870
    30  GB    Great Britain 4397
    31  GE          Georgia 2194
    32  GR           Greece 1200
    33  GT        Guatemala 1229
    34  HK        Hong Kong 2075
    35  HR          Croatia 1487
    36  HU          Hungary 1514
    37  ID        Indonesia 3200
    38  IN            India 1692
    39  IQ             Iraq 1200
    40  IR             Iran 1499
    41  IS          Iceland 1624
    42  IT            Italy 2277
    43  JO           Jordan 1203
    44  JP            Japan 1353
    45  KE            Kenya 1266
    46  KG       Kyrgyzstan 1200
    47  KR            Korea 1245
    48  KZ       Kazakhstan 1276
    49  LB          Lebanon 1200
    50  LT        Lithuania 1448
    51  LV           Latvia 1335
    52  LY            Libya 1196
    53  MA          Morocco 1200
    54  ME       Montenegro 1003
    55  MK  North Macedonia 1117
    56  MM          Myanmar 1200
    57  MN         Mongolia 1638
    58  MO            Macau 1023
    59  MV         Maldives 1039
    60  MX           Mexico 1741
    61  MY         Malaysia 1313
    62  NG          Nigeria 1237
    63  NI        Nicaragua 1200
    64 NIR Northern Ireland  447
    65  NL      Netherlands 4549
    66  NO           Norway 1122
    67  NZ      New Zealand 1057
    68  PE             Peru 1400
    69  PH      Philippines 1200
    70  PK         Pakistan 1995
    71  PL           Poland 1352
    72  PR      Puerto Rico 1127
    73  PT         Portugal 1215
    74  RO          Romania 2870
    75  RS           Serbia 2545
    76  RU           Russia 3635
    77  SE           Sweden 1194
    78  SG        Singapore 2012
    79  SI         Slovenia 1075
    80  SK         Slovakia 2632
    81  TH         Thailand 1500
    82  TJ       Tajikistan 1200
    83  TN          Tunisia 1208
    84  TR           Turkey 2415
    85  TW           Taiwan 1223
    86  UA          Ukraine 2901
    87  US    United States 2596
    88  UY          Uruguay 1000
    89  UZ       Uzbekistan 1250
    90  VE        Venezuela 1190
    91  VN          Vietnam 1200
    92  ZW         Zimbabwe 1215

``` r
wvs_countries(wave = 7)
```


    COUNTRY INFORMATION
    Wave: 7

       ISO          Country    N
    1   AD          Andorra 1004
    2   AM          Armenia 1223
    3   AR        Argentina 1003
    4   AU        Australia 1813
    5   BD       Bangladesh 1200
    6   BO          Bolivia 2067
    7   BR           Brazil 1762
    8   CA           Canada 4018
    9   CL            Chile 1000
    10  CN            China 3036
    11  CO         Colombia 1520
    12  CY           Cyprus 1000
    13  CZ   Czech Republic 1200
    14  DE          Germany 1528
    15  EC          Ecuador 1200
    16  EG            Egypt 1200
    17  ET         Ethiopia 1230
    18  GB    Great Britain 2609
    19  GR           Greece 1200
    20  GT        Guatemala 1229
    21  HK        Hong Kong 2075
    22  ID        Indonesia 3200
    23  IN            India 1692
    24  IQ             Iraq 1200
    25  IR             Iran 1499
    26  JO           Jordan 1203
    27  JP            Japan 1353
    28  KE            Kenya 1266
    29  KG       Kyrgyzstan 1200
    30  KR            Korea 1245
    31  KZ       Kazakhstan 1276
    32  LB          Lebanon 1200
    33  LY            Libya 1196
    34  MA          Morocco 1200
    35  MM          Myanmar 1200
    36  MN         Mongolia 1638
    37  MO            Macau 1023
    38  MV         Maldives 1039
    39  MX           Mexico 1741
    40  MY         Malaysia 1313
    41  NG          Nigeria 1237
    42  NI        Nicaragua 1200
    43 NIR Northern Ireland  447
    44  NL      Netherlands 2145
    45  NZ      New Zealand 1057
    46  PE             Peru 1400
    47  PH      Philippines 1200
    48  PK         Pakistan 1995
    49  PR      Puerto Rico 1127
    50  RO          Romania 1257
    51  RS           Serbia 1046
    52  RU           Russia 1810
    53  SG        Singapore 2012
    54  SK         Slovakia 1200
    55  TH         Thailand 1500
    56  TJ       Tajikistan 1200
    57  TN          Tunisia 1208
    58  TR           Turkey 2415
    59  TW           Taiwan 1223
    60  UA          Ukraine 1289
    61  US    United States 2596
    62  UY          Uruguay 1000
    63  UZ       Uzbekistan 1250
    64  VE        Venezuela 1190
    65  VN          Vietnam 1200
    66  ZW         Zimbabwe 1215

A `wvs_countries()` call with a `countries` argument returns the iso,
country name, and number of observations for the requested country or
countries. The countries list is somewhat flexible with names.

``` r
wvs_countries(countries = c("USA", "GB"))
```


    COUNTRY INFORMATION

      ISO       Country    N
    1  US United States 2596
    2  GB Great Britain 4397

``` r
wvs_countries(c("United States", "Great Britain"))
```


    COUNTRY INFORMATION

      ISO       Country    N
    1  US United States 2596
    2  GB Great Britain 4397

### Check Item Availability

Use `wvs_items()` to display available EVS/WVS survey items. Additional
arguments such as `group`, `vars`, or `columns` can be used to filter or
customize the output.

``` r
wvs_items(
  group = "Perceptions of life",
  vars = c("A001", "A002", "A003", "A004", "A005"),
  columns = c("label", "direction", "min", "max")
)
```

                                   label direction min max
    A001       Important in life: Family         1  -1   4
    A002      Important in life: Friends         1  -1   4
    A003 Important in life: Leisure time         1  -1   4
    A004     Important in life: Politics         1  -1   4
    A005         Important in life: Work         1  -1   4

### Cultural Dimensions

Use `wvs_dimensions()` to display the defined cultural dimensions and
their construction/source information.

``` r
wvs_dimensions()
```

                     dimension                           title    group     type
    1                Tradition Traditional vs Secular-Rational     Core     mean
    2                 Survival     Survival vs Self-Expression     Core     mean
    3              Institution             Institutional Trust     Main     mean
    4                    Moral            Moral Permissiveness     Main     mean
    5                   Gender                 Gender Equality     Main     mean
    6                    Civic                Civic Engagement     Main     mean
    7                Political            Political Engagement Extended     mean
    8                   Social                    Social Trust Extended     mean
    9                 Economic              Market Orientation Extended     mean
    10               Wellbeing            Subjective Wellbeing Extended     mean
    11               Democracy       Liberal Democracy Support Extended     mean
    12      TraditionalSecular Traditional vs Secular-Rational      Dev     mean
    13  SurvivalSelfExpression     Survival vs Self-Expression      Dev     mean
    14                Autonomy                        Autonomy      Dev contrast
    15         Postmaterialism                 Postmaterialism      Dev   lookup
    16        LifeSatisfaction               Life Satisfaction      Dev     mean
    17          PersonalAgency                 Personal Agency      Dev     mean
    18             Religiosity                     Religiosity      Dev     mean
    19      SupernaturalBelief             Supernatural Belief      Dev     mean
    20    SexualPermissiveness           Sexual Permissiveness      Dev     mean
    21 EndOfLifePermissiveness      End-of-life Permissiveness      Dev     mean
    22           CivicMorality                  Civic Morality      Dev     mean
    23  PoliticalParticipation         Political Participation      Dev     mean
    24       PoliticalInterest              Political Interest      Dev     mean
    25      InstitutionalTrust             Institutional Trust      Dev     mean
    26        DemocraticValues               Democratic Values      Dev     mean
    27        EconomicIdeology               Economic Ideology      Dev     mean
    28    GenderTraditionalism           Gender Traditionalism      Dev     mean
    29        FilialObligation               Filial Obligation      Dev     mean
    30    FamilyTraditionalism           Family Traditionalism      Dev     mean
    31        Environmentalism                Environmentalism      Dev     mean
    32               WorkEthic                      Work Ethic      Dev     mean
    33      NationalAttachment             National Attachment      Dev     mean
    34          GlobalIdentity                 Global Identity      Dev     mean
    35   ImmigrationAcceptance          Immigration Acceptance      Dev     mean
    36        GeneralizedTrust               Generalized Trust      Dev     mean
    37           OutgroupTrust                  Outgroup Trust      Dev     mean
    38     SecurityOrientation            Security Orientation      Dev     mean
