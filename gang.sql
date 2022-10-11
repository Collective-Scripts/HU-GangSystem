INSERT INTO `addon_account` (name, label, shared) VALUES
	('society_gang1', 'Gang 1', 1),
	('society_gang2', 'Gang 2', 1),
	('society_gang3', 'Gang 3', 1),
	('society_gang4', 'Gang 4', 1),
	('society_gang5', 'Gang 5', 1)
;

INSERT INTO `datastore` (name, label, shared) VALUES
	('society_gang1', 'Gang 1', 1),
	('society_gang2', 'Gang 2', 1),
	('society_gang3', 'Gang 3', 1),
	('society_gang4', 'Gang 4', 1),
	('society_gang5', 'Gang 5', 1)
;

INSERT INTO `jobs` (name, label) VALUES
	('gang1', 'Gang 1'),
	('gang2', 'Gang 2'),
	('gang3', 'Gang 3'),
	('gang4', 'Gang 4'),
	('gang5', 'Gang 5')
;

INSERT INTO `job_grades` (job_name, grade, name, label, salary, skin_male, skin_female) VALUES
	('gang1',0,'g1','NEOPHYTES',0,'{}','{}'),
	('gang1',1,'g2','LEADER',0,'{}','{}'),
	('gang1',2,'g3','HITMAN',0,'{}','{}'),
	('gang1',3,'g4','OG',0,'{}','{}'),
	('gang1',4,'boss','FOUNDER',0,'{}','{}'),
	
	('gang2',0,'g1','Prospect',0,'{}','{}'),
	('gang2',1,'g2','Juniors',0,'{}','{}'),
	('gang2',2,'g3','Veteran',0,'{}','{}'),
	('gang2',3,'g4','OG',0,'{}','{}'),
	('gang2',4,'boss','Patron',0,'{}','{}'),
	
	('gang3',0,'g1','Prospect',0,'{}','{}'),
	('gang3',1,'g2','Juniors',0,'{}','{}'),
	('gang3',2,'g3','Veteran',0,'{}','{}'),
	('gang3',3,'g4','OG',0,'{}','{}'),
	('gang3',4,'boss','Patron',0,'{}','{}'),

	('gang4',0,'g1','Prospect',0,'{}','{}'),
	('gang4',1,'g2','Juniors',0,'{}','{}'),
	('gang4',2,'g3','Veteran',0,'{}','{}'),
	('gang4',3,'g4','OG',0,'{}','{}'),
	('gang4',4,'boss','Patron',0,'{}','{}'),

	('gang5',0,'g1','Prospect',0,'{}','{}'),
	('gang5',1,'g2','Juniors',0,'{}','{}'),
	('gang5',2,'g3','Veteran',0,'{}','{}'),
	('gang5',3,'g4','OG',0,'{}','{}'),
	('gang5',4,'boss','Patron',0,'{}','{}')
;
