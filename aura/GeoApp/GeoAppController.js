({
    create : function(component, event, helper) {
        var query = "SELECT Id, Name, Data__c FROM Setting__c WHERE Name = 'Google Geolocation API'";
        component.find("utils").execute("c.getQueryData",{"query":query},function(response){
            var result = response[0];
            component.set("v.settings", JSON.parse(result.Data__c));
            var list = [
                {
                    "BuildingID": "a00F000000KzqBA",
                    "GeographyName": "Weesperstraat 61-105, Noord-Holland"
                },
                {
                    "BuildingID": "a000G00000TTThn",
                    "GeographyName": "Strawinskylaan 3101, Noord-Holland"
                },
                {
                    "BuildingID": "a00F000000Dz9pX",
                    "GeographyName": "Weteringschans 165c, Noord-Holland"
                },
                {
                    "BuildingID": "a000G00000TSeCG",
                    "GeographyName": "Andrés Arguibel 2860, Buenos Aires"
                },
                {
                    "BuildingID": "a000G00000Rf7za",
                    "GeographyName": "Av. del Libertador 1000, Buenos Aires"
                },
                {
                    "BuildingID": "a000G00000OooS0",
                    "GeographyName": "Esmeralda 950, Buenos Aires"
                },
                {
                    "BuildingID": "a000G00000Qm9Vu",
                    "GeographyName": "1372 Peachtree St NW, Georgia"
                },
                {
                    "BuildingID": "a000G00000T8UMq",
                    "GeographyName": "Terminus 100, Georgia"
                },
                {
                    "BuildingID": "a000G00000Opzhx",
                    "GeographyName": "1175 Peachtree St NE, Georgia"
                },
                {
                    "BuildingID": "a00F000000LxTlK",
                    "GeographyName": "Tower Place 100, Georgia"
                },
                {
                    "BuildingID": "a00F000000EI6bW",
                    "GeographyName": "600 Congress Ave, Texas"
                },
                {
                    "BuildingID": "a00F000000Mlm2f",
                    "GeographyName": "11801 Domain Blvd, Texas"
                },
                {
                    "BuildingID": "a00F000000LgRpr",
                    "GeographyName": "3300 N Interstate Hwy 35, Texas"
                },
                {
                    "BuildingID": "a000G00000SaDJa",
                    "GeographyName": "221 W 6th St, Texas"
                },
                {
                    "BuildingID": "a000G00000TS5C5",
                    "GeographyName": "801 Barton Springs Rd, Texas"
                },
                {
                    "BuildingID": "a000G00000SbQrm",
                    "GeographyName": "Carrer de Tànger, Catalunya"
                },
                {
                    "BuildingID": "a00F000000LKjaM",
                    "GeographyName": "Gev Yam Negev Park"
                },
                {
                    "BuildingID": "a000G00000TTyGI",
                    "GeographyName": "R. Sergipe, Minas Gerais"
                },
                {
                    "BuildingID": "a000G00000ScArC",
                    "GeographyName": "63 Flushing Ave, New York"
                },
                {
                    "BuildingID": "a00F000000D8di4",
                    "GeographyName": "81 Prospect St, New York"
                },
                {
                    "BuildingID": "a00F000000LfsfK",
                    "GeographyName": "81 Prospect St, New York"
                },
                {
                    "BuildingID": "a00F000000Lf3A3",
                    "GeographyName": "195 Montague St, New York"
                },
                {
                    "BuildingID": "a00F000000MkoIE",
                    "GeographyName": "109 S 5th St, New York"
                },
                {
                    "BuildingID": "a00F000000EIOSk",
                    "GeographyName": "240 Bedford Ave, New York"
                },
                {
                    "BuildingID": "a000G00000Sbo5P",
                    "GeographyName": "Alexanderstraße 1, Berlin"
                },
                {
                    "BuildingID": "a000G00000ScNMJ",
                    "GeographyName": "Eichhornstraße 3, Berlin"
                },
                {
                    "BuildingID": "a00F000000Leu2o",
                    "GeographyName": "Neue Schönhauser Str. 3-5, Berlin"
                },
                {
                    "BuildingID": "a000G00000Qk7lK",
                    "GeographyName": "Kurfürstendamm 11, Berlin"
                },
                {
                    "BuildingID": "a000G00000RgSMB",
                    "GeographyName": "Stresemannstraße 123, Berlin"
                },
                {
                    "BuildingID": "a00F000000Leu2j",
                    "GeographyName": "Potsdamer Platz, Berlin"
                },
                {
                    "BuildingID": "a000G00000TT7Is",
                    "GeographyName": "Stralauer Allee 6, Berlin"
                },
                {
                    "BuildingID": "a000G00000PYWz0",
                    "GeographyName": "43, Karnataka"
                },
                {
                    "BuildingID": "a000G00000Rfhmq",
                    "GeographyName": "Cinnabar Hills, Karnataka"
                },
                {
                    "BuildingID": "a000G00000T6xv6",
                    "GeographyName": "Latitude, Karnataka"
                },
                {
                    "BuildingID": "a000G00000Sb9Cd",
                    "GeographyName": "Prestige Atlanta 80 Feet Main Road, Karnataka"
                },
                {
                    "BuildingID": "a000G00000TTzMr",
                    "GeographyName": "Ac. 100, Bogotá"
                },
                {
                    "BuildingID": "a000G00000QkFpm",
                    "GeographyName": "Cl. 93, Bogotá"
                },
                {
                    "BuildingID": "a000G00000SZf9a",
                    "GeographyName": "Cra. 7, Bogotá"
                },
                {
                    "BuildingID": "a000G00000TU2vU",
                    "GeographyName": "1 Beacon St, Massachusetts"
                },
                {
                    "BuildingID": "a000G00000RgHTu",
                    "GeographyName": "200 Portland St, Massachusetts"
                },
                {
                    "BuildingID": "a000G00000TS5CK",
                    "GeographyName": "33 Arch Street, Massachusetts"
                },
                {
                    "BuildingID": "a000G00000TUbBJ",
                    "GeographyName": "501 Boylston St, Massachusetts"
                },
                {
                    "BuildingID": "a00F00000092DXa",
                    "GeographyName": "51 Melcher St, Massachusetts"
                },
                {
                    "BuildingID": "a000G00000Oocid",
                    "GeographyName": "625 Massachusetts Ave, Massachusetts"
                },
                {
                    "BuildingID": "a000G00000SbHAI",
                    "GeographyName": "1 Beacon St, Massachusetts"
                },
                {
                    "BuildingID": "a00F00000092DU8",
                    "GeographyName": "745 Atlantic Ave, Massachusetts"
                },
                {
                    "BuildingID": "a00F000000OWwYe",
                    "GeographyName": "31 St James Ave, Massachusetts"
                },
                {
                    "BuildingID": "a00F00000094bpq",
                    "GeographyName": "220 N Green St, Illinois"
                },
                {
                    "BuildingID": "a00F000000LKkN4",
                    "GeographyName": "332 S Michigan Ave, Illinois"
                },
                {
                    "BuildingID": "a00F000000Mkq3E",
                    "GeographyName": "20 W Kinzie St, Illinois"
                },
                {
                    "BuildingID": "a00F000000MlNy3",
                    "GeographyName": "125 S Clark St, Illinois"
                },
                {
                    "BuildingID": "a00F000000FT2NJ",
                    "GeographyName": "111 W Illinois St, Illinois"
                },
                {
                    "BuildingID": "a000G00000PWNzb",
                    "GeographyName": "100 S State St, Illinois"
                },
                {
                    "BuildingID": "a000G00000PZY8f",
                    "GeographyName": "615 S College St, North Carolina"
                },
                {
                    "BuildingID": "a000G00000T7qss",
                    "GeographyName": "7300 Dallas Pkwy, Texas"
                },
                {
                    "BuildingID": "a000G00000Sa3Mw",
                    "GeographyName": "5049 Edwards Ranch Rd, Texas"
                },
                {
                    "BuildingID": "a000G00000PZ5w4",
                    "GeographyName": "7700 Windrose Ave, Texas"
                },
                {
                    "BuildingID": "a000G00000Opmby",
                    "GeographyName": "Thanksgiving Tower, Texas"
                },
                {
                    "BuildingID": "a00F000000OYD7M",
                    "GeographyName": "1920 McKinney Ave, Texas"
                },
                {
                    "BuildingID": "a000G00000Oq2rB",
                    "GeographyName": "80 M St SE, District of Columbia"
                },
                {
                    "BuildingID": "a000G00000PZlvc",
                    "GeographyName": "600 H St NE, District of Columbia"
                },
                {
                    "BuildingID": "a00F0000009XXMA",
                    "GeographyName": "718 7th St NW, District of Columbia"
                },
                {
                    "BuildingID": "a00F000000L1GiX",
                    "GeographyName": "2221 S Clark St, Virginia"
                },
                {
                    "BuildingID": "a00F000000BuHiH",
                    "GeographyName": "1875 Connecticut Ave NW, District of Columbia"
                },
                {
                    "BuildingID": "a00F000000MkVCN",
                    "GeographyName": "1875 K St NW, District of Columbia"
                },
                {
                    "BuildingID": "a00F000000Ml3gg",
                    "GeographyName": "1348 Florida Ave NW, District of Columbia"
                },
                {
                    "BuildingID": "a00F000000OXrxp",
                    "GeographyName": "1775 Tysons Blvd, Virginia"
                },
                {
                    "BuildingID": "a00F000000MlmhS",
                    "GeographyName": "1400 G St NW, District of Columbia"
                },
                {
                    "BuildingID": "a00F0000009XXMF",
                    "GeographyName": "641 S St NW, District of Columbia"
                },
                {
                    "BuildingID": "a000G00000ScTVl",
                    "GeographyName": "Platina Tower, Haryana"
                },
                {
                    "BuildingID": "a000G00000RejiM",
                    "GeographyName": "1144 15th St, Colorado"
                },
                {
                    "BuildingID": "a00F000000LgIcm",
                    "GeographyName": "2420 17th St, Colorado"
                },
                {
                    "BuildingID": "a000G00000Sd7zy",
                    "GeographyName": "1200 17th St, Colorado"
                },
                {
                    "BuildingID": "a00F000000LgIch",
                    "GeographyName": "1550 Wewatta St, Colorado"
                },
                {
                    "BuildingID": "a000G00000PZST4",
                    "GeographyName": "1001 Woodward Ave, Michigan"
                },
                {
                    "BuildingID": "a000G00000Onl6V",
                    "GeographyName": "1449 Woodward Ave, Michigan"
                },
                {
                    "BuildingID": "a000G00000TSeCB",
                    "GeographyName": "1 George's Quay, County Dublin"
                },
                {
                    "BuildingID": "a000G00000TUgUy",
                    "GeographyName": "N Wall Quay, County Dublin"
                },
                {
                    "BuildingID": "a000G00000ScK7T",
                    "GeographyName": "Iveagh Court, County Dublin"
                },
                {
                    "BuildingID": "a000G00000TSeBr",
                    "GeographyName": "Paseo de Los Virreyes 65, Jalisco"
                },
                {
                    "BuildingID": "a000G00000Rf6pA",
                    "GeographyName": "Haifa, Haifa District"
                },
                {
                    "BuildingID": "a000G00000TT7Ii",
                    "GeographyName": "Taunusanlage 8, Hessen"
                },
                {
                    "BuildingID": "a000G00000PZv7g",
                    "GeographyName": "Junghofstraße 22, Hessen"
                },
                {
                    "BuildingID": "a000G00000Sa8rZ",
                    "GeographyName": "Ballindamm 40, Hamburg"
                },
                {
                    "BuildingID": "a000G00000SbX3l",
                    "GeographyName": "Gänsemarkt 43, Hamburg"
                },
                {
                    "BuildingID": "a000G00000PZv80",
                    "GeographyName": "Axel-Springer-Platz 3, Hamburg"
                },
                {
                    "BuildingID": "a000G00000TT78Y",
                    "GeographyName": "33 Wyndham St, Hong Kong Island"
                },
                {
                    "BuildingID": "a00F000000MlCb0",
                    "GeographyName": "Central Mansion, Hong Kong Island"
                },
                {
                    "BuildingID": "a00F000000MlMDf",
                    "GeographyName": "33 Lockhart Rd, Hong Kong Island"
                },
                {
                    "BuildingID": "a000G00000Ql3fT",
                    "GeographyName": "708 S Main St, Texas"
                },
                {
                    "BuildingID": "a000G00000Sb4H0",
                    "GeographyName": "2700 Post Oak Blvd, Texas"
                },
                {
                    "BuildingID": "a000G00000SbJiy",
                    "GeographyName": "King George St 32, Jerusalem District"
                },
                {
                    "BuildingID": "a000G00000PZN9t",
                    "GeographyName": "1828 Walnut St, Missouri"
                },
                {
                    "BuildingID": "a000G00000T7OWC",
                    "GeographyName": "3200 Park Center Dr, California"
                },
                {
                    "BuildingID": "a000G00000PX8uZ",
                    "GeographyName": "3900 W Alameda Ave, California"
                },
                {
                    "BuildingID": "a000G00000PX3WB",
                    "GeographyName": "Constellation Place, California"
                },
                {
                    "BuildingID": "a00F000000Mkkms",
                    "GeographyName": "5792 W Jefferson Blvd, California"
                },
                {
                    "BuildingID": "a00F000000ELKqe",
                    "GeographyName": "811 W 7th St, California"
                },
                {
                    "BuildingID": "a00F000000LxTnx",
                    "GeographyName": "The Gas Company Tower, California"
                },
                {
                    "BuildingID": "a00F00000092DTe",
                    "GeographyName": "7083 Hollywood Blvd, California"
                },
                {
                    "BuildingID": "a00F000000Ml3hK",
                    "GeographyName": "925 N La Brea Ave, California"
                },
                {
                    "BuildingID": "a00F000000OYD8A",
                    "GeographyName": "100 W Broadway, California"
                },
                {
                    "BuildingID": "a00F000000OYD8L",
                    "GeographyName": "1240 Rosecrans Ave, California"
                },
                {
                    "BuildingID": "a000G00000RfYrR",
                    "GeographyName": "Pacific Design Center, California"
                },
                {
                    "BuildingID": "a00F000000Leutt",
                    "GeographyName": "177 E Colorado Blvd, California"
                },
                {
                    "BuildingID": "a00F000000Mktpx",
                    "GeographyName": "12655 Jefferson Blvd, California"
                },
                {
                    "BuildingID": "a00F000000Kn1lY",
                    "GeographyName": "312 Arizona Ave, California"
                },
                {
                    "BuildingID": "a00F000000GNOY9",
                    "GeographyName": "520 Broadway, California"
                },
                {
                    "BuildingID": "a00F000000Leuuc",
                    "GeographyName": "200 Spectrum Center Dr, California"
                },
                {
                    "BuildingID": "a000G00000Qm9Vp",
                    "GeographyName": "1601 Vine St, California"
                },
                {
                    "BuildingID": "a000G00000TTzMh",
                    "GeographyName": "Av. Juan de Aliaga 347, Municipalidad Metropolitana de Lima"
                },
                {
                    "BuildingID": "a000G00000SaGWX",
                    "GeographyName": "Av. Victor Andrés Belaúnde 147 Via Principal 133"
                },
                {
                    "BuildingID": "a000G00000SclV1",
                    "GeographyName": "131 Finsbury Pavement, England"
                },
                {
                    "BuildingID": "a000G00000SclmQ",
                    "GeographyName": "1 Poultry, England"
                },
                {
                    "BuildingID": "a000G00000SaLMc",
                    "GeographyName": "120 Moorgate, England"
                },
                {
                    "BuildingID": "a00F000000L1GWn",
                    "GeographyName": "2 Leman St, England"
                },
                {
                    "BuildingID": "a000G00000OoVkj",
                    "GeographyName": "71-91 Aldwych, England"
                },
                {
                    "BuildingID": "a000G00000PXqEl",
                    "GeographyName": "15 Bishopsgate, England"
                },
                {
                    "BuildingID": "a000G00000Sc2IT",
                    "GeographyName": "Halsbury House, England"
                },
                {
                    "BuildingID": "a00F000000LxTl0",
                    "GeographyName": "15 Grays Inn Rd, England"
                },
                {
                    "BuildingID": "a00F000000GX9rs",
                    "GeographyName": "9 Devonshire Square, England"
                },
                {
                    "BuildingID": "a000G00000ScZxr",
                    "GeographyName": "Shepherds Bush Rd, England"
                },
                {
                    "BuildingID": "a000G00000SIpbR",
                    "GeographyName": "12 Hammersmith Grove, England"
                },
                {
                    "BuildingID": "a000G00000SbJEB",
                    "GeographyName": "97 Hackney Rd, England"
                },
                {
                    "BuildingID": "a000G00000SaLMX",
                    "GeographyName": "Kings Place, England"
                },
                {
                    "BuildingID": "a000G00000OoVke",
                    "GeographyName": "115 Mare St, England"
                },
                {
                    "BuildingID": "a000G00000Oobao",
                    "GeographyName": "33 Queen St, England"
                },
                {
                    "BuildingID": "a000G00000Sbs8L",
                    "GeographyName": "North West House, England"
                },
                {
                    "BuildingID": "a000G00000RgSqG",
                    "GeographyName": "51 Eastcheap, England"
                },
                {
                    "BuildingID": "a00F000000Gy84Y",
                    "GeographyName": "Moor Place, England"
                },
                {
                    "BuildingID": "a00F000000LeTjD",
                    "GeographyName": "41 Corsham St, England"
                },
                {
                    "BuildingID": "a000G00000Safgh",
                    "GeographyName": "City Rd, England"
                },
                {
                    "BuildingID": "a000G00000RgMlP",
                    "GeographyName": "207 Old St, England"
                },
                {
                    "BuildingID": "a00F000000MkjZ0",
                    "GeographyName": "2 Eastbourne Terrace, England"
                },
                {
                    "BuildingID": "a000G00000ReUHj",
                    "GeographyName": "125 Shaftesbury Ave, England"
                },
                {
                    "BuildingID": "a000G00000QllS3",
                    "GeographyName": "1 Mark Square, England"
                },
                {
                    "BuildingID": "a00F000000MkbrB",
                    "GeographyName": "15 Great Chapel St, England"
                },
                {
                    "BuildingID": "a00F000000EJuHM",
                    "GeographyName": "2 Sheraton St, England"
                },
                {
                    "BuildingID": "a00F000000AmgOq",
                    "GeographyName": "New Kings Beam House, England"
                },
                {
                    "BuildingID": "a000G00000Oq4hk",
                    "GeographyName": "33 Stamford St, England"
                },
                {
                    "BuildingID": "a00F000000KoTGp",
                    "GeographyName": "1 Primrose St, England"
                },
                {
                    "BuildingID": "a000G00000TSOoc",
                    "GeographyName": "2-4 Fairchild Place"
                },
                {
                    "BuildingID": "a000G00000TSOlA",
                    "GeographyName": "Hewett St, England"
                },
                {
                    "BuildingID": "a000G00000PXqEq",
                    "GeographyName": "50 St Katharine's Way, England"
                },
                {
                    "BuildingID": "a00F000000Mkvx3",
                    "GeographyName": "138 Holborn, England"
                },
                {
                    "BuildingID": "a000G00000QDya4",
                    "GeographyName": "The Shell Centre, England"
                },
                {
                    "BuildingID": "a000G00000SIrta",
                    "GeographyName": "Paseo de la Castellana, Comunidad de Madrid"
                },
                {
                    "BuildingID": "a000G00000T7FLa",
                    "GeographyName": "Paseo de la Castellana, Comunidad de Madrid"
                },
                {
                    "BuildingID": "a000G00000SbFqM",
                    "GeographyName": "One St Peter's Square, England"
                },
                {
                    "BuildingID": "a000G00000ReOT4",
                    "GeographyName": "Quay St, England"
                },
                {
                    "BuildingID": "a000G00000RfGQD",
                    "GeographyName": "152 Elizabeth St, Victoria"
                },
                {
                    "BuildingID": "a000G00000PZtC4",
                    "GeographyName": "401 Collins St, Victoria"
                },
                {
                    "BuildingID": "a00F000000OY9Vo",
                    "GeographyName": "78 SW 7th St, Florida"
                },
                {
                    "BuildingID": "a00F000000EIOSL",
                    "GeographyName": "Lincoln Building, Florida"
                },
                {
                    "BuildingID": "a000G00000ReK2t",
                    "GeographyName": "2222 Ponce De Leon Blvd, Florida"
                },
                {
                    "BuildingID": "a00F000000Ml470",
                    "GeographyName": "1 NE 1st Ave, Florida"
                },
                {
                    "BuildingID": "a00F000000LxUKv",
                    "GeographyName": "429 Lenox Ave, Florida"
                },
                {
                    "BuildingID": "a000G00000T8Rvk",
                    "GeographyName": "Tsvetnoy Blvd"
                },
                {
                    "BuildingID": "a000G00000T8Rvf",
                    "GeographyName": "Butyrskiy Val Ulitsa"
                },
                {
                    "BuildingID": "a000G00000TS5CF",
                    "GeographyName": "1350 Lagoon Ave, Minnesota"
                },
                {
                    "BuildingID": "a000G00000QlrwW",
                    "GeographyName": "225 South 6th St, Minnesota"
                },
                {
                    "BuildingID": "a000G00000OoCxJ",
                    "GeographyName": "1275 Avenue des Canadiens-de-Montréal, Québec"
                },
                {
                    "BuildingID": "a00F000000Ledot",
                    "GeographyName": "3 Place Ville Marie, Quebec"
                },
                {
                    "BuildingID": "a000G00000TSeC6",
                    "GeographyName": "Blvd. Antonio L. Rodríguez, Nuevo León"
                },
                {
                    "BuildingID": "a000G00000T6wHx",
                    "GeographyName": "Oskar-von-Miller-Ring 20, Bayern"
                },
                {
                    "BuildingID": "a000G00000QkXcG",
                    "GeographyName": "Bandra Kurla Complex, Maharashtra"
                },
                {
                    "BuildingID": "a000G00000Sc4V7",
                    "GeographyName": "The Masterpiece, Maharashtra"
                },
                {
                    "BuildingID": "a000G00000T7DUd",
                    "GeographyName": "Hindustan C. Bus Stop, Maharashtra"
                },
                {
                    "BuildingID": "a000G00000TSeBw",
                    "GeographyName": "Nápoles 47, Ciudad de México"
                },
                {
                    "BuildingID": "a000G00000RgMSk",
                    "GeographyName": "Paseo de Los Tamarindos, Ciudad de México"
                },
                {
                    "BuildingID": "a000G00000ScTVq",
                    "GeographyName": "Bv. Adolfo Ruíz Cortines 3720, Veracruz"
                },
                {
                    "BuildingID": "a000G00000QlbRA",
                    "GeographyName": "Blvd. Miguel de Cervantes Saavedra 169, Ciudad de México"
                },
                {
                    "BuildingID": "a000G00000ReYRs",
                    "GeographyName": "Insurgentes Sur 601, Ciudad de México"
                },
                {
                    "BuildingID": "a000G00000Oq8U5",
                    "GeographyName": "Calle Montes Urales 424, Ciudad de México"
                },
                {
                    "BuildingID": "a000G00000TS1wD",
                    "GeographyName": "Palmas Hills, Estado de México"
                },
                {
                    "BuildingID": "a000G00000QlP1r",
                    "GeographyName": "Av. Javier Barros Sierra, Ciudad de México"
                },
                {
                    "BuildingID": "a00F000000OYBmj",
                    "GeographyName": "Paseo de la Reforma, Ciudad de México"
                },
                {
                    "BuildingID": "a00F000000MkxZz",
                    "GeographyName": "Varsovia 36, Ciudad de México"
                },
                {
                    "BuildingID": "a000G00000QlDEK",
                    "GeographyName": "901 Woodland St, Tennessee"
                },
                {
                    "BuildingID": "a000G00000QlDEt",
                    "GeographyName": "140 4th Ave N, Tennessee"
                },
                {
                    "BuildingID": "a000G00000TSswN",
                    "GeographyName": "750 Lexington Ave, New York"
                },
                {
                    "BuildingID": "a000G00000PYXrw",
                    "GeographyName": "950 6th Ave, New York"
                },
                {
                    "BuildingID": "a000G00000Sa59k",
                    "GeographyName": "11 Park Pl, New York"
                },
                {
                    "BuildingID": "a00F000000KnUzq",
                    "GeographyName": "110 Wall St, New York"
                },
                {
                    "BuildingID": "a000G00000RgO1Z",
                    "GeographyName": "115 Broadway, New York"
                },
                {
                    "BuildingID": "a00F000000ELmdO",
                    "GeographyName": "120 E 23rd St, New York"
                },
                {
                    "BuildingID": "a000G00000T6pP3",
                    "GeographyName": "125 W 25th St, New York"
                },
                {
                    "BuildingID": "a000G00000SbKeP",
                    "GeographyName": "135 Madison Ave, New York"
                },
                {
                    "BuildingID": "a000G00000QE6lk",
                    "GeographyName": "135 W 41st St, New York"
                },
                {
                    "BuildingID": "a00F00000092DT0",
                    "GeographyName": "175 Varick St, New York"
                },
                {
                    "BuildingID": "a000G00000TTFWj",
                    "GeographyName": "18 W 18th St, New York"
                },
                {
                    "BuildingID": "a000G00000QE6lf",
                    "GeographyName": "205 Hudson S, New York"
                },
                {
                    "BuildingID": "a00F00000092DXL",
                    "GeographyName": "222 Broadway, New York"
                },
                {
                    "BuildingID": "a00F0000009X7cg",
                    "GeographyName": "25 Broadway, New York"
                },
                {
                    "BuildingID": "a000G00000TUPe3",
                    "GeographyName": "30 W 21st St, New York"
                },
                {
                    "BuildingID": "a00F000000Mknzd",
                    "GeographyName": "300 Park Ave, New York"
                },
                {
                    "BuildingID": "a00F000000LeN1A",
                    "GeographyName": "404 5th Ave, New York"
                },
                {
                    "BuildingID": "a000G00000T6pXm",
                    "GeographyName": "408 Broadway, New York"
                },
                {
                    "BuildingID": "a00F000000EI6bq",
                    "GeographyName": "205 E 42nd St, New York"
                },
                {
                    "BuildingID": "a00F000000Lf3HF",
                    "GeographyName": "428 Broadway, New York"
                },
                {
                    "BuildingID": "a000G00000T7OR2",
                    "GeographyName": "500 7th Ave, New York"
                },
                {
                    "BuildingID": "a00F000000MlmIP",
                    "GeographyName": "524 Broadway, New York"
                },
                {
                    "BuildingID": "a000G00000TS5CU",
                    "GeographyName": "53 Beach St, New York"
                },
                {
                    "BuildingID": "a000G00000PaHws",
                    "GeographyName": "575 5th Ave, New York"
                },
                {
                    "BuildingID": "a00F000000AmQXs",
                    "GeographyName": "79 Madison Ave, New York"
                },
                {
                    "BuildingID": "a00F000000FUzL3",
                    "GeographyName": "85 Broad St, New York"
                },
                {
                    "BuildingID": "a000G00000Opokc",
                    "GeographyName": "88 University Pl, New York"
                },
                {
                    "BuildingID": "a00F00000092BkD",
                    "GeographyName": "54 W 40th St, New York"
                },
                {
                    "BuildingID": "a00F000000FT25I",
                    "GeographyName": "115 W 18th St, New York"
                },
                {
                    "BuildingID": "a00F000000MlmIo",
                    "GeographyName": "E 57th St, New York"
                },
                {
                    "BuildingID": "a00F00000092DSq",
                    "GeographyName": "349 5th Ave, New York"
                },
                {
                    "BuildingID": "a00F000000FTlGi",
                    "GeographyName": "11 John St, New York"
                },
                {
                    "BuildingID": "a00F000000MkoHQ",
                    "GeographyName": "450 Lexington Ave, New York"
                },
                {
                    "BuildingID": "a00F000000MkoIJ",
                    "GeographyName": "5 W 125th St, New York"
                },
                {
                    "BuildingID": "a00F000000Lf3AS",
                    "GeographyName": "33 Irving Pl, New York"
                },
                {
                    "BuildingID": "a00F00000092Bk8",
                    "GeographyName": "261 Madison Ave, New York"
                },
                {
                    "BuildingID": "a00F00000092DSl",
                    "GeographyName": "1 Little W 12th St, New York"
                },
                {
                    "BuildingID": "a00F000000Alu6L",
                    "GeographyName": "401 Park Ave S, New York"
                },
                {
                    "BuildingID": "a00F000000L1Gh0",
                    "GeographyName": "315 W 36th St, New York"
                },
                {
                    "BuildingID": "a00F00000092DSv",
                    "GeographyName": "154 Grand St, New York"
                },
                {
                    "BuildingID": "a00F000000L1GgJ",
                    "GeographyName": "1460 Broadway, New York"
                },
                {
                    "BuildingID": "a000G00000OpokN",
                    "GeographyName": "Tower 49, New York"
                },
                {
                    "BuildingID": "a000G00000OpokD",
                    "GeographyName": "311 W 43rd St, New York"
                },
                {
                    "BuildingID": "a000G00000OpokS",
                    "GeographyName": "142 W 57th St, New York"
                },
                {
                    "BuildingID": "a00F000000Alu5h",
                    "GeographyName": "379 W Broadway, New York"
                },
                {
                    "BuildingID": "a000G00000T7Ggq",
                    "GeographyName": "92 Av. des Champs-Élysées, Île-de-France"
                },
                {
                    "BuildingID": "a000G00000RfjZ1",
                    "GeographyName": "64-66 Rue des Archives, Île-de-France"
                },
                {
                    "BuildingID": "a000G00000Sa8w6",
                    "GeographyName": "40 Rue du Colisée, Île-de-France"
                },
                {
                    "BuildingID": "a00F000000MlJao",
                    "GeographyName": "30 Rue la Fayette, Île-de-France"
                },
                {
                    "BuildingID": "a000G00000OpohT",
                    "GeographyName": "China, Beijing Shi"
                },
                {
                    "BuildingID": "a000G00000OpohE",
                    "GeographyName": "China, Beijing Shi"
                },
                {
                    "BuildingID": "a000G00000Saw5y",
                    "GeographyName": "China, Beijing Shi"
                },
                {
                    "BuildingID": "a000G00000T79If",
                    "GeographyName": "19 San Li Tun Lu, Beijing Shi"
                },
                {
                    "BuildingID": "a000G00000PYOP5",
                    "GeographyName": "15 Guang Shun Dao, Tianjin Shi"
                },
                {
                    "BuildingID": "a00F000000MkxZL",
                    "GeographyName": "Five Penn Center, Pennsylvania"
                },
                {
                    "BuildingID": "a000G00000OpKOf",
                    "GeographyName": "1900 Market St, Pennsylvania"
                },
                {
                    "BuildingID": "a00F000000KXNzd",
                    "GeographyName": "1010 N Hancock St, Pennsylvania"
                },
                {
                    "BuildingID": "a00F000000MkyW1",
                    "GeographyName": "1430 Walnut St, Pennsylvania"
                },
                {
                    "BuildingID": "a000G00000TT9R8",
                    "GeographyName": "920 SW 6th Ave, Oregon"
                },
                {
                    "BuildingID": "a00F000000GxJrv",
                    "GeographyName": "22 NW 8th Ave, Oregon"
                },
                {
                    "BuildingID": "a000G00000PXIoS",
                    "GeographyName": "700 SW 5th Ave, Oregon"
                },
                {
                    "BuildingID": "a000G00000RgNc8",
                    "GeographyName": "27-01 Queens Plaza N, New York"
                },
                {
                    "BuildingID": "a00F000000Lg5Qh",
                    "GeographyName": "3537 36th St, New York"
                },
                {
                    "BuildingID": "a000G00000T8UMl",
                    "GeographyName": "110 Corcoran St, North Carolina"
                },
                {
                    "BuildingID": "a000G00000RgO2v",
                    "GeographyName": "1 Glenwood Ave, North Carolina"
                },
                {
                    "BuildingID": "a000G00000Rfhn5",
                    "GeographyName": "Av. Pasteur, Rio de Janeiro"
                },
                {
                    "BuildingID": "a000G00000RefKE",
                    "GeographyName": "Av. Alm. Barroso, Rio de Janeiro"
                },
                {
                    "BuildingID": "a000G00000SIjeu",
                    "GeographyName": "495 Visconde de Piraja Avenue, Rio de Janeiro"
                },
                {
                    "BuildingID": "a000G00000T7IxT",
                    "GeographyName": "Av. das Nações Unidas, São Paulo"
                },
                {
                    "BuildingID": "a000G00000TSnEt",
                    "GeographyName": "Av. Paulista, São Paulo"
                },
                {
                    "BuildingID": "a000G00000RefRi",
                    "GeographyName": "Av. das Nações Unidas, São Paulo"
                },
                {
                    "BuildingID": "a000G00000T7xrS",
                    "GeographyName": "Av. Angélica, São Paulo"
                },
                {
                    "BuildingID": "a000G00000PXH3m",
                    "GeographyName": "Av. Paulista, São Paulo"
                },
                {
                    "BuildingID": "a000G00000TTzN6",
                    "GeographyName": "R. Butantã, São Paulo"
                },
                {
                    "BuildingID": "a000G00000Qlgdd",
                    "GeographyName": "Av. Pres. Juscelino Kubitschek, São Paulo"
                },
                {
                    "BuildingID": "a000G00000QkWJn",
                    "GeographyName": "R. Prof. Atílio Innocenti, São Paulo"
                },
                {
                    "BuildingID": "a000G00000TT3Hp",
                    "GeographyName": "Av. Apoquindo 5950, Región Metropolitana"
                },
                {
                    "BuildingID": "a000G00000Sccas",
                    "GeographyName": "8910 University Center Ln, California"
                },
                {
                    "BuildingID": "a00F000000OYD7b",
                    "GeographyName": "Comerica Bank Building, California"
                },
                {
                    "BuildingID": "a000G00000T7OWW",
                    "GeographyName": "4144 4th Ave, Washington"
                },
                {
                    "BuildingID": "a000G00000TSOlU",
                    "GeographyName": "Qwest Plaza, Washington"
                },
                {
                    "BuildingID": "a000G00000T7Ixd",
                    "GeographyName": "255 S King St, Washington"
                },
                {
                    "BuildingID": "a000G00000T6wI7",
                    "GeographyName": "925 4th Ave, Washington"
                },
                {
                    "BuildingID": "a000G00000RgLrA",
                    "GeographyName": "1099 Stewart St, Washington"
                },
                {
                    "BuildingID": "a00F000000K7uYl",
                    "GeographyName": "107 Spring St, Washington"
                },
                {
                    "BuildingID": "a000G00000OoIBG",
                    "GeographyName": "400 Bellevue Way NE, Washington"
                },
                {
                    "BuildingID": "a00F0000009XXOE",
                    "GeographyName": "500 Yale Ave N, Washington"
                },
                {
                    "BuildingID": "a00F000000LgIcr",
                    "GeographyName": "1601 5th Ave, Washington"
                },
                {
                    "BuildingID": "a00F000000OX4ih",
                    "GeographyName": "48-1 Jeodong 2(i)-ga"
                },
                {
                    "BuildingID": "a00F000000Ml7nO",
                    "GeographyName": "373 Gangnam-daero"
                },
                {
                    "BuildingID": "a000G00000ScZyf",
                    "GeographyName": "50 Jong-ro 1-gil"
                },
                {
                    "BuildingID": "a000G00000QkG10",
                    "GeographyName": "Daechi 2(i)-dong, 서울특별시"
                },
                {
                    "BuildingID": "a000G00000TTzMc",
                    "GeographyName": "Gangnam-gu, Seoul"
                },
                {
                    "BuildingID": "a000G00000T7DNB",
                    "GeographyName": "416 Hangang-daero"
                },
                {
                    "BuildingID": "a000G00000Sa5Lx",
                    "GeographyName": "Gangnam-gu, Seoul"
                },
                {
                    "BuildingID": "a000G00000T7DN6",
                    "GeographyName": "Gangnam-gu, Seoul"
                },
                {
                    "BuildingID": "a00F000000Mkp0D",
                    "GeographyName": "600 California St, California"
                },
                {
                    "BuildingID": "a000G00000PYAZ3",
                    "GeographyName": "201 Spear St, California"
                },
                {
                    "BuildingID": "a000G00000Sd0Lp",
                    "GeographyName": "391 San Antonio Rd, California"
                },
                {
                    "BuildingID": "a000G00000SccGl",
                    "GeographyName": "401 San Antonio Rd, California"
                },
                {
                    "BuildingID": "a000G00000PZQrf",
                    "GeographyName": "650 California Street, California"
                },
                {
                    "BuildingID": "a00F000000E0sk3",
                    "GeographyName": "2120 University Ave, California"
                },
                {
                    "BuildingID": "a000G00000ReUHG",
                    "GeographyName": "1111 Broadway, California"
                },
                {
                    "BuildingID": "a00F000000Kn1fB",
                    "GeographyName": "1161 Mission St, California"
                },
                {
                    "BuildingID": "a000G00000OoOut",
                    "GeographyName": "Two Embarcadero Center, California"
                },
                {
                    "BuildingID": "a00F00000092DTP",
                    "GeographyName": "25 Taylor St, California"
                },
                {
                    "BuildingID": "a000G00000QmZvV",
                    "GeographyName": "655 Montgomery St, California"
                },
                {
                    "BuildingID": "a00F000000Kn1io",
                    "GeographyName": "995 Market St, California"
                },
                {
                    "BuildingID": "a000G00000SIxUC",
                    "GeographyName": "44 Montgomery, California"
                },
                {
                    "BuildingID": "a000G00000Sbd2e",
                    "GeographyName": "415 Mission St, California"
                },
                {
                    "BuildingID": "a00F00000092DTU",
                    "GeographyName": "156 2nd St, California"
                },
                {
                    "BuildingID": "a00F000000FvQSo",
                    "GeographyName": "535 Mission Street, California"
                },
                {
                    "BuildingID": "a000G00000TUor9",
                    "GeographyName": "60 Anson Rd"
                },
                {
                    "BuildingID": "a000G00000SceOY",
                    "GeographyName": "71 Robinson Rd"
                },
                {
                    "BuildingID": "a000G00000SZWE2",
                    "GeographyName": "15 Beach Rd"
                },
                {
                    "BuildingID": "a000G00000T8QQE",
                    "GeographyName": "36 Robinson Rd"
                },
                {
                    "BuildingID": "a000G00000T8QQO",
                    "GeographyName": "2 Science Park Dr"
                },
                {
                    "BuildingID": "a000G00000T8QQT",
                    "GeographyName": "8 Claymore Hill"
                },
                {
                    "BuildingID": "a000G00000T79Ik",
                    "GeographyName": "100 Century Ave, Shanghai Shi"
                },
                {
                    "BuildingID": "a000G00000PX8uv",
                    "GeographyName": "Zhong Nan Xin Cun （ Huai Hai Zhong Lu ）, Shanghai Shi"
                },
                {
                    "BuildingID": "a000G00000TTAcM",
                    "GeographyName": "1155 Fangdian Rd, Shanghai Shi"
                },
                {
                    "BuildingID": "a000G00000T7941",
                    "GeographyName": "819 Nanjing Rd Pedestrian St, Shanghai Shi"
                },
                {
                    "BuildingID": "a00F000000MlCZY",
                    "GeographyName": "696 Wei Hai Lu, Shanghai Shi"
                },
                {
                    "BuildingID": "a000G00000QlPG0",
                    "GeographyName": "Hua Xia Gao Jia Lu, Shanghai Shi"
                },
                {
                    "BuildingID": "a000G00000Opmbt",
                    "GeographyName": "588 Yan An Dong Lu, Shanghai Shi"
                },
                {
                    "BuildingID": "a00F000000MkoI4",
                    "GeographyName": "135 Yan Ping Lu, Shanghai Shi"
                },
                {
                    "BuildingID": "a00F000000MlCZi",
                    "GeographyName": "2 Yunnan S Rd, Shanghai Shi"
                },
                {
                    "BuildingID": "a00F000000MkoI9",
                    "GeographyName": "75 E Santa Clara St, California"
                },
                {
                    "BuildingID": "a000G00000PY5i9",
                    "GeographyName": "333 George St, New South Wales"
                },
                {
                    "BuildingID": "a00F000000MlOlW",
                    "GeographyName": "5 Martin Pl, New South Wales"
                },
                {
                    "BuildingID": "a00F000000MlMLV",
                    "GeographyName": "100 Harris St, New South Wales"
                },
                {
                    "BuildingID": "a00F000000BOTi2",
                    "GeographyName": "Dubnov St 7, Tel Aviv District"
                },
                {
                    "BuildingID": "a00F000000OX050",
                    "GeographyName": "HaPelech St 7, Tel Aviv District"
                },
                {
                    "BuildingID": "a00F000000BOTk3",
                    "GeographyName": "1 Shankar St"
                },
                {
                    "BuildingID": "a00F000000Mkq3J",
                    "GeographyName": "Ibn Gabirol St 30, Tel Aviv District"
                },
                {
                    "BuildingID": "a000G00000Sa8wQ",
                    "GeographyName": "Derech Menachem Begin, Tel Aviv District"
                },
                {
                    "BuildingID": "a00F000000BOTiW",
                    "GeographyName": "Aluf Kalman Magen St, Tel Aviv District"
                },
                {
                    "BuildingID": "a000G00000Sa1tb",
                    "GeographyName": "Roppongi, Tokyo"
                },
                {
                    "BuildingID": "a000G00000Sa1tv",
                    "GeographyName": "Ginza, Tokyo"
                },
                {
                    "BuildingID": "a000G00000TTyG8",
                    "GeographyName": "Uchisaiwaicho, Tokyo"
                },
                {
                    "BuildingID": "a000G00000T8UN5",
                    "GeographyName": "Jingumae, Tokyo"
                },
                {
                    "BuildingID": "a000G00000ScZyB",
                    "GeographyName": "Chiyoda, Tokyo"
                },
                {
                    "BuildingID": "a000G00000Sa1tg",
                    "GeographyName": "Shinbashi, Tokyo"
                },
                {
                    "BuildingID": "a000G00000TS5CA",
                    "GeographyName": "1 University Ave, Ontario"
                },
                {
                    "BuildingID": "a000G00000RfYuP",
                    "GeographyName": "33 Bloor St E, Ontario"
                },
                {
                    "BuildingID": "a000G00000PZcdG",
                    "GeographyName": "249 Richmond St W, Ontario"
                },
                {
                    "BuildingID": "a000G00000SIPWJ",
                    "GeographyName": "555 Burrard St, British Columbia"
                },
                {
                    "BuildingID": "a000G00000PZcxj",
                    "GeographyName": "595 Burrard St, British Columbia"
                }
            ];
            helper.manageGeo(component,list,0);
        },function(error){
            component.find("utils").showError(error);
        });
        
    }
})