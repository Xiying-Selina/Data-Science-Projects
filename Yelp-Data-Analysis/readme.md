# Overview
In this project, we performed analysis on Yelp review to help start a new restaurant. 

# Data source
[data from:](https://www.kaggle.com/datasets/yelp-dataset/yelp-dataset).
> This dataset is a subset of Yelp's businesses, reviews, and user data. It was originally put together for the Yelp Dataset Challenge which is a chance for students to conduct research or analysis on Yelp's data and share their discoveries. In the most recent dataset you'll find information about businesses across 8 metropolitan areas in the USA and Canada.
> This dataset contains five JSON files and the user agreement.

# Contents
## 1. loading.ipynb
In this file, we read five **json** files to pandas fataframe. These five datasets contains review, checkin, business, and tip. It is noticing that for review and tip files, we read them in chunks since it exceeds the limit of writing up one time. Then, we lunched a **MySQL** instance and created engine to load the data to sql.

## 2. query-sql.ipynb
In this file, we checked the connection of database and created some tables to see if it works. After that, we made up 10 questions on the yelp data which would help to start a new restaurant and wrote 10 queries in **sql** to answer. 

## 3. query-python.ipynb
This file is similar to the last one. But here we levegated the analysis using **pandas and numpy** instead of sql.
