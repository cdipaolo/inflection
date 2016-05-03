# make_dataset.py
#
# Takes the raw Yelp Academic Dataset in
# /data/raw and uploads it into an sqlite3
# database.

from math import floor
import sqlite3
import json

# whether to upload which sections of the data
# into the sqlite3 db
BUS, USER, CHECKIN, REVIEW = True, True, True, True

# lengths of the different files for
# progress reports
lengths = {
    "business": 77445,
    "user": 552339,
    "checkin": 55569,
    "review": 2225213
}

conn = sqlite3.connect('data/yelp.db')
c = conn.cursor()

# read through json dataset line by
# line, uploading data to sqlite3.
if BUS:
    print('==> Uploading business data to sqlite')
    with open('data/raw/yelp_academic_dataset_business.json', 'r') as f:
        i = 0
        total = lengths["business"]
        for business in f:
            # convert from string json object
            # to a map
            b = json.loads(business)
            
            # insert the business into the
            # database
            c.execute('''INSERT INTO business
                            (business_id, name, city, state,
                             longitude, latitude, stars, review_count,
                             categories, attributes, type)
                         VALUES
                            (?,?,?,?,?,?,?,?,?,?,?)''',
                      (b['business_id'], b['name'], b['city'],
                       b['state'], b['longitude'], b['latitude'],
                       b['stars'], b['review_count'], json.dumps(b['categories']),
                       json.dumps(b['attributes']), b['type']
                      )
            )
            i += 1
            if i%500 == 0:
                conn.commit()
            if i % floor(total/10) == 0:
                print('--  uploaded business {}/{} = {:0.2f}'.format(i,total, i/total))
print('==> Finished uploading business data')

if USER:
    print('==> Uploading user data to sqlite')
    with open('data/raw/yelp_academic_dataset_user.json', 'r') as f:
        i = 0
        total = lengths["user"]
        for user in f:
            # convert user from json string to map
            u = json.loads(user)

            # insert user into db
            c.execute('''INSERT INTO users
                            (user_id, name, review_count,
                             average_stars)
                         VALUES
                            (?,?,?,?)''',
                      (u['user_id'], u['name'], u['review_count'],
                       u['average_stars'])                 
            )
            i += 1
            if i%500 == 0:
                conn.commit()
            if i % floor(total/10) == 0:
                print('--  uploaded user {}/{} = {:0.2f}'.format(i,total, i/total))
    print('==> Finished uploading user data')

if CHECKIN:
    print('==> Uploading check-in data to business dataset')
    with open('data/raw/yelp_academic_dataset_checkin.json', 'r') as f:
        i = 0
        total = lengths["checkin"]
        for checkin in f:
            # convert checkin from json to map
            ch = json.loads(checkin)

            # add checkin data to business table
            c.execute('''UPDATE business
                         SET checkin_info = (?)
                         WHERE business_id == ?''',
                      (json.dumps(ch['checkin_info']), ch['business_id'])
            )
            i += 1
            if i%500 == 0:
                conn.commit()
            if i % floor(total/10) == 0:
                print('--  uploaded checkin {}/{} = {:0.2f}'.format(i,total, i/total))
    print('==> Finished uploading checkin data')

if REVIEW:
    print('==> Uploading review data to sqlite')
    with open('data/raw/yelp_academic_dataset_review.json','r') as f:
        i = 0
        total = lengths["review"]
        for review in f:
            # convert review from json to map
            r = json.loads(review)

            # add review into db
            c.execute('''INSERT INTO review
                            (user_id, business_id, stars, text, timestamp)
                         VALUES
                            (?,?,?,?,?)''',
                      (r['user_id'], r['business_id'], r['stars'],
                       r['text'], r['date'])
            )
            i += 1
            if i%500 == 0:
                conn.commit()
            if i % floor(total/10) == 0:
                print('--  uploaded review {}/{} = {:0.2f}'.format(i,total, i/total))
    print('==> Finished uploading review data')

conn.commit()
conn.close()
