# Add a declarative step here for populating the DB with movies.

Given /the following movies exist/ do |movies_table|
  movies_table.hashes.each do |movie|
    Movie.create movie
  end
end

Then /(.*) seed movies should exist/ do | n_seeds |
  expect(Movie.count).to eq n_seeds.to_i
end

# Make sure that one string (regexp) occurs before or after another one
#   on the same page

Then /I should see "(.*)" before "(.*)"/ do |e1, e2|
  movie_titles = all("#movies tr td:nth-child(1)").map(&:text).select { |title| [e1, e2].include? title }
  expect(movie_titles.first).to eq e1
end

# Make it easier to express checking or unchecking several boxes at once
#  "When I uncheck the following ratings: PG, G, R"
#  "When I check the following ratings: G"

When /^(?:|I )(un)?check the following ratings: (.*)/ do |uncheck, rating_list|
  ratings_ids = rating_list.split(", ").map { |rating| "ratings_#{rating}" }
  ratings_ids.each { |rating_id| uncheck ? uncheck(rating_id) : check(rating_id) }
end

Then /I should see all the movies/ do
  expect(all("#movies tbody tr").count).to eq Movie.count
end

Then(/^I should only see movies with checked ratings$/) do
  checked_ratings = Movie.all_ratings.select { |rating| find("#ratings_#{rating}").checked? }
  shown_ratings = all("#movies tr td:nth-child(2)").map(&:text).uniq

  expect(shown_ratings).to match_array checked_ratings
end
