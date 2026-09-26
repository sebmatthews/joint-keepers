-- Register livestock: fixed seed data for the Joint Keepers demo.
-- Every name, place, phone number, holding number and tag number is invented.
-- Phone numbers are from the range Ofcom reserves for drama, 01632 960000 to 960999 (confirmed, ofcom.org.uk 'Telephone numbers for use in TV and radio drama programmes', read 26 September 2026). 'DM' holding numbers and 'LV' tags are fictional formats.

INSERT INTO Keeper VALUES (1, 'Ffion Marlow', 'Brackenridge Farm, Brackenridge, Demoshire', '01632 960101');
INSERT INTO Keeper VALUES (2, 'Tobias Greenhalgh', 'Lower Muddlecombe Farm, Muddlecombe, Demoshire', '01632 960102');
INSERT INTO Keeper VALUES (3, 'Priya Oakley', 'Hollowmere Farm, Hollowmere, Demoshire', '01632 960103');
INSERT INTO Keeper VALUES (4, 'Duncan Fairweather', 'Stonebarrow Holding, Stonebarrow, Demoshire', '01632 960104');
INSERT INTO Keeper VALUES (5, 'Margaret Holloway', 'Upper Muddlecombe Farm, Muddlecombe, Demoshire', '01632 960105');

INSERT INTO Holding VALUES (1, 'DM/101/0001', 'Brackenridge Farm', 'Brackenridge Lane, Brackenridge, Demoshire');
INSERT INTO Holding VALUES (2, 'DM/102/0002', 'Lower Muddlecombe Farm', 'Combe Road, Muddlecombe, Demoshire');
INSERT INTO Holding VALUES (3, 'DM/103/0003', 'Hollowmere Farm', 'Mere Lane, Hollowmere, Demoshire');
INSERT INTO Holding VALUES (4, 'DM/104/0004', 'Stonebarrow Holding', 'Barrow Hill, Stonebarrow, Demoshire');
INSERT INTO Holding VALUES (5, 'DM/102/0005', 'Upper Muddlecombe Farm', 'Top Road, Muddlecombe, Demoshire');
INSERT INTO Holding VALUES (6, 'DM/105/0006', 'Kettleby Down', 'Down Road, Kettleby, Demoshire');

INSERT INTO Animal VALUES (1, 'LV00010000', 'Pig', '2023-12-10', 1, 1);
INSERT INTO Animal VALUES (2, 'LV00010037', 'Goat', '2022-10-24', 3, 3);
INSERT INTO Animal VALUES (3, 'LV00010074', 'Cattle', '2022-12-08', 6, 1);
INSERT INTO Animal VALUES (4, 'LV00010111', 'Sheep', '2022-05-30', 4, 4);
INSERT INTO Animal VALUES (5, 'LV00010148', 'Pig', '2022-05-05', 5, 5);
INSERT INTO Animal VALUES (6, 'LV00010185', 'Sheep', '2022-11-20', 3, 3);
INSERT INTO Animal VALUES (7, 'LV00010222', 'Cattle', '2021-01-28', 2, 2);
INSERT INTO Animal VALUES (8, 'LV00010259', 'Pig', '2023-05-18', 2, 2);
INSERT INTO Animal VALUES (9, 'LV00010296', 'Cattle', '2023-01-03', 3, 3);
INSERT INTO Animal VALUES (10, 'LV00010333', 'Pig', '2024-02-05', 4, 4);
INSERT INTO Animal VALUES (11, 'LV00010370', 'Goat', '2022-05-29', 5, 5);
INSERT INTO Animal VALUES (12, 'LV00010407', 'Sheep', '2025-02-17', 1, 1);
INSERT INTO Animal VALUES (13, 'LV00010444', 'Cattle', '2021-02-19', 1, 1);
INSERT INTO Animal VALUES (14, 'LV00010481', 'Sheep', '2021-07-02', 2, 2);
INSERT INTO Animal VALUES (15, 'LV00010518', 'Sheep', '2022-01-01', 3, 3);
INSERT INTO Animal VALUES (16, 'LV00010555', 'Cattle', '2024-02-14', 4, 4);
INSERT INTO Animal VALUES (17, 'LV00010592', 'Sheep', '2023-02-11', 5, 5);
INSERT INTO Animal VALUES (18, 'LV00010629', 'Pig', '2024-10-24', 5, 5);
INSERT INTO Animal VALUES (19, 'LV00010666', 'Sheep', '2023-09-18', 1, 1);
INSERT INTO Animal VALUES (20, 'LV00010703', 'Cattle', '2025-02-27', 2, 2);
INSERT INTO Animal VALUES (21, 'LV00010740', 'Cattle', '2025-04-28', 3, 3);
INSERT INTO Animal VALUES (22, 'LV00010777', 'Goat', '2021-12-25', 4, 4);
INSERT INTO Animal VALUES (23, 'LV00010814', 'Sheep', '2023-04-26', 4, 4);
INSERT INTO Animal VALUES (24, 'LV00010851', 'Cattle', '2024-11-01', 4, 4);
INSERT INTO Animal VALUES (25, 'LV00010888', 'Sheep', '2021-08-08', 1, 1);
INSERT INTO Animal VALUES (26, 'LV00010925', 'Cattle', '2024-02-01', 3, 3);
INSERT INTO Animal VALUES (27, 'LV00010962', 'Sheep', '2021-11-03', 1, 1);
INSERT INTO Animal VALUES (28, 'LV00010999', 'Cattle', '2023-03-30', 4, 4);
INSERT INTO Animal VALUES (29, 'LV00011036', 'Cattle', '2021-11-14', 5, 5);
INSERT INTO Animal VALUES (30, 'LV00011073', 'Cattle', '2021-11-18', 6, 1);

INSERT INTO Movement VALUES (1, 7, 1, 2, '2021-09-24');
INSERT INTO Movement VALUES (2, 27, 3, 1, '2022-07-20');
INSERT INTO Movement VALUES (3, 3, 3, 6, '2023-06-06');
INSERT INTO Movement VALUES (4, 6, 6, 2, '2023-08-15');
INSERT INTO Movement VALUES (5, 2, 2, 3, '2023-08-21');
INSERT INTO Movement VALUES (6, 6, 2, 3, '2023-10-03');
INSERT INTO Movement VALUES (7, 23, 5, 4, '2024-01-17');
INSERT INTO Movement VALUES (8, 26, 2, 3, '2024-07-27');
INSERT INTO Movement VALUES (9, 18, 6, 5, '2025-05-17');
INSERT INTO Movement VALUES (10, 24, 6, 3, '2025-06-08');
INSERT INTO Movement VALUES (11, 24, 3, 4, '2025-07-16');
INSERT INTO Movement VALUES (12, 12, 6, 1, '2025-12-12');
