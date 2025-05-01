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
                                                    on update cascade ,
     foreign key(event_ID) references Events(ID)    on delete cascade 
                                                    on update cascade ,
     foreign key(eval_ID) references Evaluation(ID) on delete cascade 
                                                    on update cascade 
);



