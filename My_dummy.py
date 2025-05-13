import random
import faker
from datetime import timedelta, date, datetime, timedelta
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
		fest_val.append(f"({year}, '{start_date}','{end_date}', {location_id}, {img_val})")
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
	global venue_objects
	venue_objects = []
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
		venue_objects.append({'id':id, 'name':name, 'description':description, 'max_capacity':max_capacity, 'tech_req':tech_req, 'img_val':img_val})
		venue_val.append(f"({id}, '{name}','{description}', {max_capacity}, '{tech_req}', {img_val})")
	f.write(",\n".join(venue_val) + ";\n\n")

def fake_event(f):
	f.write("INSERT INTO `event` (`id`, `festival_year`, `name`, `event_date`, `start_time`, `end_time`, `poster`) VALUES\n")
	global event_objects
	event_objects = []
	event_val = []
	global event_dates
	event_dates = {} 

	img = list(range(61,71))
	random.shuffle(img)
	i=0
	for j in range(1,N_EVENTS+1):
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
		event_dates[j] = event_date
		event_objects.append({'id': j, 'festival_year': festival_year, 'name': name, 'event_date': event_date, 'start_time': start_time, 'end_time': end_time, 'duration': duration, 'img_val': img_val})
		event_val.append(f"({j}, '{festival_year}','{name}', '{event_date}', '{start_time}','{end_time}', {img_val})")
	f.write(",\n".join(event_val) + ";\n\n")


def fake_event_venue(f):
	f.write("INSERT INTO `event_venue` (`event_id`, `venue_id`) VALUES\n")
	global event_venue_dict
	event_venue_vals = []
	event_venue_dict = {}
	for i in range(1, N_EVENTS+1):
		venue_id = random.randint(1,N_VENUES)
		event_venue_vals.append(f"({i}, {venue_id})")
		event_venue_dict.update({i:venue_id})
	f.write(",\n".join(event_venue_vals) + ";\n\n")


#An tlk alaksoume ta durations na einai different kanto me normalized weights (they all add to 1 and then multiply them with the active duration)
def fake_performance(f):
	f.write("INSERT INTO `performance` (`id`, `event_id`, `venue_id`, `performance_type`, `start_time`, `duration`, `sequence_number`, `break_duration`) VALUES\n")
	global perf_id
	global performance_object
	performance_object = []
	perf_id=1
	performance_vals = []
	performance_types = ['headline', 'Special guest', 'other']
	for event in event_objects:
		numOfPerformancesPerEvent=random.randint(5,7)
		duration_breaks = [timedelta(seconds=random.randint(5,30)*60) for _ in range(numOfPerformancesPerEvent)]
		total_break_duration = sum(duration_breaks, timedelta())
		active_duration = event['duration'] - total_break_duration
		performance_duration = active_duration/numOfPerformancesPerEvent
		currentTime = event['start_time']
		for i in range(numOfPerformancesPerEvent):
			performance_object.append({'id': perf_id, 'event_id': event['id'], 'venue_id': event_venue_dict[event['id']], 'performance_type': ('warm up' if i==0 else performance_types[random.randint(0,2)]), 'start_time': currentTime, 'duration': performance_duration, 'sequence_number': i+1, 'break_duration': duration_breaks[i]})
			performance_vals.append(f"({perf_id}, {event['id']}, {event_venue_dict[event['id']]}, '{'warm up' if i==0 else performance_types[random.randint(0,2)]}', '{currentTime}', '{performance_duration}', '{i+1}', '{duration_breaks[i]}')")
			perf_id=perf_id+1
			currentTime = currentTime + performance_duration + duration_breaks[i]
	f.write(",\n".join(performance_vals) + ";\n\n")


def fake_performance_artistband(f):
    f.write("INSERT INTO `performance_artistband` (`performance_id`, `artist_band_id`) VALUES\n")
    perf_artist_values = []
    # Dictionary to track artist performances: {artist_id: [performance_ids]}
    artist_performances = {}
    # Dictionary to track years each artist performed: {artist_id: set(years)}
    artist_years = {}
    
    for i in range(1, perf_id):
        artistband_id = random.randint(1, N_ARTISTBANDS)
        # Get current performance details
        current_perf = next(perf for perf in performance_object if perf['id'] == i)
        current_event = next(event for event in event_objects if event['id'] == current_perf['event_id'])
        current_date = current_event.get('event_date')
        current_year = current_date.year if hasattr(current_date, 'year') else int(str(current_date).split('-')[0])
        current_start = current_perf['start_time']
        current_end = current_start + current_perf['duration']
        
        # Check for conflicts (simultaneous performances and consecutive years)
        has_conflict = False
        
        while True:
            has_conflict = False
            
            # Check for simultaneous performance conflict
            if artistband_id in artist_performances:
                for other_perf_id in artist_performances[artistband_id]:
                    other_perf = next(perf for perf in performance_object if perf['id'] == other_perf_id)
                    other_event = next(event for event in event_objects if event['id'] == other_perf['event_id'])
                    
                    # Skip if not on the same date
                    if other_event.get('event_date') != current_date:
                        continue
                        
                    other_start = other_perf['start_time']
                    other_end = other_start + other_perf['duration']
                    
                    # Check for time overlap (same logic as in the trigger)
                    if ((other_start <= current_start and other_end > current_start) or
                        (other_start < current_end and other_end >= current_end) or
                        (other_start >= current_start and other_end <= current_end)):
                        has_conflict = True
                        break
            
            # Check for consecutive years constraint
            if not has_conflict and artistband_id in artist_years:
                years = sorted(list(artist_years[artistband_id]))
                
                # Add the current year to check if it would create > 3 consecutive years
                test_years = years + [current_year] if current_year not in years else years
                test_years = sorted(list(set(test_years)))  # Ensure uniqueness
                
                # Check for more than 3 consecutive years
                consecutive_count = 1
                max_consecutive = 1
                
                for j in range(1, len(test_years)):
                    if test_years[j] == test_years[j-1] + 1:
                        consecutive_count += 1
                        max_consecutive = max(max_consecutive, consecutive_count)
                    else:
                        consecutive_count = 1
                
                if max_consecutive >= 2:
                    has_conflict = True
            
            # If no conflict, break the loop
            if not has_conflict:
                break
                
            # Try a different artist
            artistband_id = random.randint(1, N_ARTISTBANDS)
        
        # Add this performance to the artist's tracking
        if artistband_id not in artist_performances:
            artist_performances[artistband_id] = []
        artist_performances[artistband_id].append(i)
        
        # Add the year to the artist's years
        if artistband_id not in artist_years:
            artist_years[artistband_id] = set()
        artist_years[artistband_id].add(current_year)
        
        perf_artist_values.append(f"({i}, {artistband_id})")
    
    f.write(",\n".join(perf_artist_values) + ";\n\n")



def fake_tickets(f):
    f.write("INSERT INTO tickets (EAN13, visitor_id, category, purchase_date, price, payment_method, event_id, isActivated) VALUES\n")
    tickets_vals = []
    visitor_ids = list(range(1, N_VISITORS + 1))
    random.shuffle(visitor_ids)
    visitor_events = {}
    cnt = 0

    global tickets_for_evaluation 
    tickets_for_evaluation = []  # keep this for rates
    evaluated_tickets = 0

    for i in range(N_TICKETS):
        activated = False
        EAN = "".join([str(random.randint(0, 9)) for i in range(13)])
        event_id = random.randint(1, N_EVENTS)

        owner = visitor_ids[cnt]
        cnt += 1
        if cnt >= N_VISITORS:
            random.shuffle(visitor_ids)
            cnt = 0


        while (owner in visitor_events) and (event_dates[visitor_events[owner]] == event_dates[event_id]):
            # Find a new event with a different date
            prev_date = event_dates[event_id]
            event_id = random.randint(1, N_EVENTS)
            while prev_date == event_dates[event_id]:
                event_id = random.randint(1, N_EVENTS)

        visitor_events[owner] = event_id
        event_date = event_dates[event_id]
        start_date = date(event_date.year - 1, event_date.month, event_date.day)
        purchase_date = fake.date_between(start_date=start_date, end_date=event_date)

        if evaluated_tickets <= N_EVALUATIONS:
            tickets_for_evaluation.append((owner, event_id))
            evaluated_tickets += 1
            activated = True


        R = random.randint(1, 100)
        if R < 70:
            cat = "GA"
        elif R < 98:
            cat = "BaS"
        else:
            cat = "VIP"

        if cat == "BaS":
            price = 0.0
        elif cat == "VIP":
            price = random.randint(500, 2500) + random.random()
        else:
            price = random.randint(50, 500) + random.random()

        price = round(price, 2)
        tickets_vals.append(f"('{EAN}','{owner}','{cat}','{purchase_date}',{price},'{random.choice(['CC','BC','DC','NC'])}',{event_id},{activated})")

    f.write(f",\n".join(tickets_vals) + ";\n\n")

def fake_staff(f):
    f.write("INSERT INTO `staff` (`id`, `name`, `age`, `role`, `experience_level`) VALUES\n")
    staff_vals = []
    roles = ['technical', 'security', 'support']
    experiences = ['trainee', 'beginner', 'intermediate', 'experienced', 'expert']
    for i in range(1,N_STAFF+1):
        staff_vals.append(f"({i}, '{fake.first_name() + " " + fake.last_name()}', {random.randint(18,45)}, '{random.choice(roles)}', '{random.choice(experiences)}')")
    f.write(",\n".join(staff_vals) + ";\n\n")

def fake_event_staff(f):
	f.write("INSERT INTO `event_staff` (`event_id`, `staff_id`, `assignment_date`, `shift_start`, `shift_end`) VALUES\n")
	event_staff_vals = []
	#Add event_staff logic
	for event in event_objects:
		#Calculate staff required for the event and then loop the below creation for as many IDs needed


		#Creation for specific ID
		staff_id = random.randint(1,N_STAFF)
		year, month, day = event['event_date'].year, event['event_date'].month, event['event_date'].day
		assignment_date = fake.date_between_dates(date(year-1,1,1), event['event_date'])
		#Need to combine these with time
		shift_start = fake.date_between(event['start_time'], event['end_time'])
		shift_end = fake.date_between(shift_start, event['end_time'])
		event_staff_vals.append(f"({event['id']}, {staff_id}, {assignment_date}, {shift_start}, {shift_end})")
	f.write(",\n".join(event_staff_vals) + ";\n\n")


def fake_fest_photo(f):
	f.write("INSERT INTO `festivalPhotos` (`festival_year`, `photo`) VALUES\n")
	fest_photo_val = []
	img = list(range(71,81))
	random.shuffle(img)
	for i in festival_dates:
		photo = 'NULL' if img==[] else img.pop()
		fest_photo_val.append(f"({i[0].year},{photo})")
	f.write(",\n".join(fest_photo_val) + ";\n\n")




def fake_rates(f):
    f.write("INSERT INTO rates (visitor_id, performance_id, evaluation_id, rating_date) VALUES\n")
    rate_vals = []
    cnt = 1
    for t in tickets_for_evaluation: 
        owner, event_id = t
        performance = random.choice([p['id'] for p in performance_object if p['event_id'] == event_id])
        event_date = event_dates[event_id]
        start_date = date(event_date.year, event_date.month, event_date.day) 
        rate_date = fake.date_between(start_date=start_date, end_date=date(event_date.year + 1 , 12, 31))
        
        rate_vals.append(f"({owner}, {performance}, {cnt}, '{rate_date}')")
        cnt += 1   

    f.write(f",;".join(rate_vals) + "\n\n")


with open("festival_fake_data.sql", "w") as f:
	f.write("BEGIN;\n\n")

	#f.write("DELETE FROM `festival_location`;\nDELETE FROM `performance_artistband`;\nDELETE FROM `location`;\nDELETE FROM `entity_image`;\nDELETE FROM `rates`;\nDELETE FROM `evaluation`;\nDELETE FROM `performance`;\nDELETE FROM `event_venue`;\nDELETE FROM `venue`;\nDELETE FROM `visitor_tickets`;\nDELETE FROM `artist_band_genre`;\nDELETE FROM `genre`;\nDELETE FROM `image`;\nDELETE FROM `resale_transactions`;\nDELETE FROM `buyer_queue`;\nDELETE FROM `seller_queue`;\nDELETE FROM `visitor`;\nDELETE FROM `tickets`;\nDELETE FROM `event_staff`;\nDELETE FROM `event`;\nDELETE FROM `festival`;\nDELETE FROM `staff`;\nDELETE FROM `memberof`;\nDELETE FROM `artistband`;\n\n\n")

	fake_visitors(f)
	fake_images(f)
	fake_locations(f)
	fake_loc_photo(f)
	fake_artistband(f)
	fake_genres(f)
	fake_art_genre(f)
	fake_member_of(f)
	fake_festival(f)
	fake_event(f)
	fake_venue(f)
	fake_event_venue(f)
	fake_performance(f)
	fake_performance_artistband(f)
	fake_tickets(f)
	fake_evaluations(f)
	fake_rates(f)
	fake_staff(f)
	fake_event_staff(f)
	fake_fest_photo(f)
	f.write("COMMIT;\n")
