import random
import faker
from datetime import timedelta, date, datetime
from lorem_text import lorem
fake = faker.Faker()

N_VISITORS = 600
N_IMAGES = 100
N_ARTISTBANDS = 60
N_GENRES = 20
N_FESTIVALS = 10
N_LOCATIONS = 25
N_EVENTS = 30
N_VENUES = 30
N_TICKETS = 1000
N_STAFF = 200
N_EVALUATIONS = 650

def get_random_date(start_year=2000, end_year=2025):
	return fake.date_between(start_date=date(start_year, 1, 1), end_date=date(end_year, 12, 31))


def fake_visitors(f):
	f.write("INSERT INTO `visitor` (`id`, `first_name`, `last_name`, `age`, `email`, `phone`) VALUES\n")
	global visitor_values
	visitor_values = []
	for i in range(1, N_VISITORS + 1):
		first_name = fake.first_name()
		last_name = fake.last_name()
		age = random.randint(18, 70)
		email = fake.email()
		phone = fake.msisdn()[0:10]
		visitor_values.append(f"({i}, '{first_name}', '{last_name}', {age}, '{email}', '{phone}')")
	f.write(",\n".join(visitor_values) + ";\n\n")

def fake_locations(f):
	f.write("INSERT INTO `location` (`id`, `address`, `geo_coordinates`, `city`, `country`, `continent`) VALUES\n")
	loc_values =[]
	for i in range(1,N_LOCATIONS+1):
		address = fake.address().replace("\n", ", ")
		geo = f"{fake.latitude():.6f},{fake.longitude():.6f}"
		city = fake.city()
		country = fake.country()
		continent = random.choice(["North America", "South America", "Europe", "Asia", "Africa", "Oceania", "Antarctica"])
		loc_values.append(f'({i}, "{address}", "{geo}", "{city}", "{country}", "{continent}")')
	f.write(",\n".join(loc_values) + ";\n\n")

def fake_images(f):
	f.write("INSERT INTO `images` (`image_id`, `description`, `image_file`) VALUES\n")
	img_values = []
	for i in range(1,N_IMAGES+1):
		description = lorem.sentence()
		image_file = f"{fake.image_url()}/"
		img_values.append(f"({i}, '{description}', '{image_file}')")
	f.write(",\n".join(img_values) + ";\n\n")

def fake_loc_photo(f):
	f.write("INSERT INTO `locationPhotos` (`location_id`, `photo`) VALUES\n")
	loc_photo_val = []
	img = list(range(21,41))
	random.shuffle(img)
	for i in range(1,N_LOCATIONS+1):
		photo = 'NULL' if img==[] else img.pop()
		loc_photo_val.append(f"({i},{photo})")
	f.write(",\n".join(loc_photo_val) + ";\n\n")



def fake_artistband(f):
	f.write("INSERT INTO `artistband` (`id`, `type`, `name`, `alias`, `birthdate_formation_date`, `website`, `instagram`,`image`) VALUES\n")
	global artistband
	artistband =[]
	artist_values =[]
	img = list(range(1,11))
	random.shuffle(img)
	for i in range(1, N_ARTISTBANDS + 1):
		ab_type = random.choices(["Artist", "Band"],weights=[80,20])[0]
		name = fake.name() if ab_type == "Artist" else fake.company()
		alias = fake.user_name() + str(i)
		birth_or_formation = get_random_date(1970, 2020)
		artistband.append([i,ab_type,birth_or_formation])
		website = fake.url()
		instagram = f"https://www.instagram.com/{fake.dga()}/"
		img_val = 'NULL' if img==[] else img.pop()
		artist_values.append(f"({i}, '{ab_type}', '{name}', '{alias}', '{birth_or_formation}', '{website}', '{instagram}',{img_val} )")
	f.write(",\n".join(artist_values) + ";\n\n")


def fake_genres(f):
	genre_hierarchy = {
		"Rock": ["Hard Rock", "Progressive Rock", "Punk Rock"],
		"Jazz": ["Smooth Jazz", "Bebop"],
		"Electronic": ["House", "Techno"],
		"Pop": ["K-Pop", "Electropop"],
		"Metal": ["Heavy Metal", "Black Metal"],
		"Classical": ["Baroque", "Romantic"]
	}
	
	f.write("INSERT INTO `genre` (`id`, `genre_name`, `parent_genre`) VALUES\n")
	genre_values = []
	genre_id = 1
	for parent, children in genre_hierarchy.items():
		genre_values.append(f"({genre_id}, '{parent}', NULL)")
		genre_id += 1
		for child in children:
			genre_values.append(f"({genre_id}, '{child}', '{parent}')")
			genre_id += 1
	
	f.write(",\n".join(genre_values) + ";\n\n")

def fake_art_genre(f):
	f.write("INSERT INTO `artist_band_genre` (`artist_band_id`, `genre_id`) VALUES\n")
	art_genre_values = []
	art_genre_id = 1
	for i in range(1, N_ARTISTBANDS+1):
		genre_id = random.randint(1,19)
		art_genre_values.append(f"({i}, {genre_id})")
	f.write(",\n".join(art_genre_values) + ";\n\n")

def fake_member_of(f):
	f.write("INSERT INTO `memberof` (`artist_id`, `band_id`, `join_date`, `leave_date`,`role`) VALUES\n")
	memberof_values = []
	artists = []
	bands =[]
	for i in artistband:
		if i[1] == 'Artist':
			artists.append(i)
		else: bands.append(i)

	for j in bands:
		for i in artists:
			if random.choices([0,1],weights=[9,1])[0]:
				join_date = get_random_date(j[2].year, 2020)
				leave_date = random.choices(['NULL', join_date + timedelta(days=random.randint(1,359)), get_random_date(join_date.year+1,2025)], weights=[7,1,2])[0]
				role = random.choice(['Drummer', 'Guitarist', 'Vocalist','Bass','Piano','Violin'])
				if leave_date == 'NULL':
					memberof_values.append(f"({i[0]}, {j[0]}, '{join_date}', NULL, '{role}')")
				else:
					memberof_values.append(f"({i[0]}, {j[0]}, '{join_date}', '{leave_date}', '{role}')")

	f.write(",\n".join(memberof_values) + ";\n\n")


def fake_festival(f):
	f.write("INSERT INTO `festival` (`year`, `start_date`, `end_date`, `location_id`, `poster`) VALUES\n")
	global festival_dates
	festival_dates = []
	fest_val = []
	locations = list(range(1,N_LOCATIONS+1))
	random.shuffle(locations)
	img = list(range(11,21))
	random.shuffle(img)
	for year in range(2015,2025):
		start_date = get_random_date(year,year)
		end_date = start_date + timedelta(days=random.randint(1,7))
		location_id = locations.pop()
		img_val = 'NULL' if img==[] else img.pop()
		festival_dates.append([start_date, end_date])
		fest_val.append(f"('{year}', '{start_date}','{end_date}', {location_id}, {img_val})")
	f.write(",\n".join(fest_val) + ";\n\n")

# def fake_fest_photo(f):
# 	f.write("INSERT INTO `festivalPhotos` (`festival_year`, `photo`) VALUES\n")
# 	fest_photo_val = []
# 	img = list(range(11,21))
# 	random.shuffle(img)
# 	for i in range(1,N_LOCATIONS+1):
# 		photo = 'NULL' if img==[] else img.pop()
# 		loc_photo_val.append(f"({i},{photo})")
# 	f.write(",\n".join(loc_photo_val) + ";\n\n")

def fake_venue(f):
	f.write("INSERT INTO `venue` (`id`, `name`, `description`, `max_capacity`, `technical_requirements`, `photo`) VALUES\n")
	global venue_id
	venue_id = []
	venue_val = []
	tech_list = ["Speakers", "Stage Lights", "Microphones", "Sound Systems", "Special Effects"]
	img = list(range(41,61))
	random.shuffle(img)
	for id in range(1,N_VENUES+1):
		name = fake.street_name()
		description = lorem.sentence()
		max_capacity = random.randint(100,350)
		tech_req = random.choices(tech_list,weights=[10,5,10,5,3],k=random.randint(1,5))
		tech_req = ','.join(map(str,tech_req))
		img_val = 'NULL' if img==[] else img.pop()
		venue_val.append(f"({id}, '{name}','{description}', {max_capacity}, '{tech_req}', {img_val})")
	f.write(",\n".join(venue_val) + ";\n\n")

def fake_event(f):
	f.write("INSERT INTO `event` (`id`, `festival_year`, `name`, `event_date`, `start_time`, `end_time`, `duration`, `poster`) VALUES\n")
	event_val = []
	global event_dates
	event_dates = {} 
	img = list(range(61,71))
	random.shuffle(img)
	i=0
	for j in range(1,N_EVENTS+1):
		print(4*(i+1) > j)
		if (4*(i+1)>j):
			festival_year = festival_dates[i][0].year
		else:
			festival_year = festival_dates[i][0].year
			i +=1
		name = fake.user_name()
		event_date = festival_dates[i][0]
		start_time = datetime.combine(event_date,datetime.strptime(fake.time(), '%H:%M:%S').time())
		end_time = start_time + timedelta(hours=random.choice([3,6,9,12]))
		duration = end_time - start_time
		img_val = 'NULL' if img==[] else img.pop()
		event_val.append(f"('{j}', '{festival_year}','{name}', '{event_date}', '{start_time}','{end_time}', '{duration}',{img_val})")
		event_dates[j] = event_date
	f.write(",\n".join(event_val) + ";\n\n")


def fake_tickets(f):
	f.write("INSERT INTO Tickets (EAN13, visitor_id, category, purchase_date, price, payment_method, event_id) VALUES\n")
	tickets_vals = []
	visitor_ids = random.shuffle(list(range(1,N_VISITORS+1)))
	visitor_events = {}
	cnt = 0 
	for i in range(N_TICKETS):
		EAN =  "".join([str(random.randint(0,9)) for i in range(13)])
		event_id = random.randint(1,N_EVENTS)
		
		owner = visitor_ids[cnt]
		cnt += 1
		if(cnt > N_VISITORS):
			visitor_ids = random.shuffle(visitor_ids)
			cnt = 0

		#for each visitor only one ticket per event 
		while (owner in visitor_events.keys() and visitor_events[owner] == event_id):
			event_id = random.randint(1,N_EVENTS)
			

		visitor_events[owner] = event_id
	

		

		year,month,day = event_dates[event_id][0:2], event_dates[event_id][3:5], event_dates[event_id][6:8]
		purchase_date = fake.date_between(start_date=date(year - 1, month, day), end_date=date(year,month,day)) #you can buy the ticket one year before the event

		R = random.randint(1,10) 
		if(R < 5):
			cat = "GA"
		elif (R < 8):
			cat = "VIP"
		else: 
			cat = "Bas"
		cat = random.choice(["GA","VIP","BaS"])
		
		if cat == "BaS" : 
			price = 0.0
		elif cat == "VIP" :
			price = random.randint(500,2500) + random.random()
		else: 
			price = random.randint(50,500) + random.random()

		price = round(price,2)
		tickets_vals.append(f"('{EAN}','{owner}','{cat}','{purchase_date}',{price},'{random.choice(["CC","BC","DC","NC"])}',{event_id})")
	f.write(",\n".join(tickets_vals) + ";\n\n")


def fake_evaluations(f):
	eval_vals = []
	f.write("INSERT INTO evaluation  (artist_performance , sound_lighting, stage_presence, organization, overall_impression) VALUES\n")
	for i in range(N_EVALUATIONS):
		artist_performance = random.randint(1,5)
		sound_lighting = random.randint(1,5)
		stage_presence = random.randint(1,5)
		organization = random.randint(1,5)
		overall_impression = random.randint(1,5)
		eval_vals.append(f"('{artist_performance}', '{sound_lighting}','{stage_presence}', {organization}, {overall_impression}),\n")
	f.write(",\n".join(eval_vals) + ";\n\n")


def fake_rates(f): 
	rates_evals = []
	f.write("INSERT INTO rates  (visitor_id ,performance_id, evaluation_id, rating_date) VALUES\n")
	for eval in range(1,N_EVALUATIONS+1):
		#you have one month to evaluate
		visitor_id = random.randint(1,N_VISITORS)
		
		eval_date = fake.date_between(start_date= date()  , end_date = date() )


	

# def fake_fest_photo(f):
# 	f.write("INSERT INTO `festivalPhotos` (`festival_year`, `photo`) VALUES\n")
# 	fest_photo_val = []
# 	img = list(range(11,21))
# 	random.shuffle(img)
# 	for i in range(1,N_LOCATIONS+1):
# 		photo = 'NULL' if img==[] else img.pop()
# 		loc_photo_val.append(f"({i},{photo})")
# 	f.write(",\n".join(loc_photo_val) + ";\n\n")


with open("festival_fake_data.sql", "w") as f:
	f.write("BEGIN;\n\n")
	fake_visitors(f)
	fake_images(f)
	fake_locations(f)
	fake_loc_photo(f)
	fake_artistband(f)
	fake_genres(f)
	fake_art_genre(f)
	fake_member_of(f)
	fake_festival(f)
	fake_venue(f)
	fake_event(f)
	fake_tickets(f)
	fake_evaluations(f)
	fake_rates(f)
	f.write("COMMIT;\n")
