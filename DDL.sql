DROP TABLE IF EXISTS Visitor;
create table Visitor
    (ID  char(5),
     first_name  varchar(15) not null, 
     last_name   varchar(15) not null,
     age         tinyint unsigned,
     email       varchar(254) check (email REGEXP '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[a-z]{2,}$'),
     phone       char(10) check (phone REGEXP '[0-9]{10}'),
     primary key (ID)   
);


DROP TABLE IF EXISTS Tickets;
create table Tickets
    (EAN13          char(13) check (EAN13 REGEXP '[0-9]{13}'),
     visitor_id     char(5), 
     
     category       varchar(3) check (category in ("GA","VIP","BaS")) not null, 
     purchase_date  date , 
     price          decimal(6,2) unsigned not null,
     payment_method char(2) check (payment_method in ("CC", "DC", "BC","NC")),
     isActivated    bool not null default 0,
     primary key (EAN13),
     foreign key visitor_id references Visitor(ID) on delete cascade 
                                                    on update cascade 
);

DROP TABLE IF EXISTS Evaluation;
create table Evaluation
    (ID int auto-increment, 
     artist_performance tinyint unsigned check(artist_performance <= 5),
     sound_lighting tinyint unsigned check (sound_lighting <= 5),
     stage_presence tinyint unsigned check (stage_presence <= 5),
     coordination tinyint unsigned check (coordination <= 5),
     overall_impression tinyint unsigned check (overall_impression <= 5),
     primary key(EvalID)
);


DROP TABLE IF EXISTS rating;
create table rating
    (visitor_ID char(5),
     event_ID char(5),
     eval_ID int ,
     foreign key(visitor_ID) references Visitor(ID) on delete cascade 
                                                    on update cascade 
     #foreign key(event_ID) references Events(ID),
     foreign key(eval_ID) references Evaluation(ID) on delete cascade 
                                                    on update cascade ,
);



#Tickets Dummy Data
/*
INSERT INTO Tickets (EAN13, category, purchase_date, price, payment_method, isActivated) VALUES ('4689153305038',       'VIP',  '2025-04-28',   '1338.88',  'DC');
INSERT INTO Tickets (EAN13, category, purchase_date, price, payment_method, isActivated) VALUES ('7486968459915',       'BaS',  '2024-01-22',   '0.0',      'DC');
INSERT INTO Tickets (EAN13, category, purchase_date, price, payment_method, isActivated) VALUES ('0853363471597',       'GA',   '2024-04-17',   '74.15',    'DC');
INSERT INTO Tickets (EAN13, category, purchase_date, price, payment_method, isActivated) VALUES ('4248301946246',       'GA',   '2025-04-20',   '299.64',   'BC');
INSERT INTO Tickets (EAN13, category, purchase_date, price, payment_method, isActivated) VALUES ('6827238846665',       'VIP',  '2025-06-23',   '2047.48',  'DC');
INSERT INTO Tickets (EAN13, category, purchase_date, price, payment_method, isActivated) VALUES ('5438084046638',       'VIP',  '2025-06-23',   '2249.91',  'NC');
INSERT INTO Tickets (EAN13, category, purchase_date, price, payment_method, isActivated) VALUES ('7312740153109',       'GA',   '2025-06-23',   '151.22',   'DC');
INSERT INTO Tickets (EAN13, category, purchase_date, price, payment_method, isActivated) VALUES ('8915326849972',       'VIP',  '2024-04-17',   '1520.25',  'CC');
INSERT INTO Tickets (EAN13, category, purchase_date, price, payment_method, isActivated) VALUES ('3921110660756',       'BaS',  '2024-01-22',   '0.0',      'DC');
INSERT INTO Tickets (EAN13, category, purchase_date, price, payment_method, isActivated) VALUES ('6358915376839',       'VIP',  '2025-06-23',   '1072.54',  'NC');
INSERT INTO Tickets (EAN13, category, purchase_date, price, payment_method, isActivated) VALUES ('2150055589692',       'GA',   '2024-09-07',   '109.98',   'CC');
INSERT INTO Tickets (EAN13, category, purchase_date, price, payment_method, isActivated) VALUES ('8410797247381',       'GA',   '2022-01-05',   '142.41',   'DC');
INSERT INTO Tickets (EAN13, category, purchase_date, price, payment_method, isActivated) VALUES ('9848540584111',       'GA',   '2023-11-23',   '434.7',    'DC');
INSERT INTO Tickets (EAN13, category, purchase_date, price, payment_method, isActivated) VALUES ('5254767543225',       'VIP',  '2024-08-16',   '2453.87',  'DC');
INSERT INTO Tickets (EAN13, category, purchase_date, price, payment_method, isActivated) VALUES ('7615851870686',       'GA',   '2024-12-22',   '118.27',   'DC');
INSERT INTO Tickets (EAN13, category, purchase_date, price, payment_method, isActivated) VALUES ('1354695711015',       'GA',   '2023-04-21',   '499.82',   'BC');
INSERT INTO Tickets (EAN13, category, purchase_date, price, payment_method, isActivated) VALUES ('3979733343817',       'BaS',  '2024-12-22',   '0.0',      'DC');
INSERT INTO Tickets (EAN13, category, purchase_date, price, payment_method, isActivated) VALUES ('0692084736043',       'VIP',  '2024-09-07',   '1912.55',  'BC');
INSERT INTO Tickets (EAN13, category, purchase_date, price, payment_method, isActivated) VALUES ('7291832513072',       'GA',   '2024-09-07',   '286.61',   'NC');
*/


