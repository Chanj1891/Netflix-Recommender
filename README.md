# Netflix-Recommender

	Open dataset and challenge to come up with an algorithm that could improve Netflix’s own ‘Cinematch’ algorithm by a certain threshold (measured by RMSE)

	Prize : $1,000,000 ! 

	Winner : Team Bellkor’s Pragmatic Chaos Algorithm (2009)
	Blend of 107 individual results

	Cinematch ? ‘uses straightforward statistical linear models with a lot of data conditioning’

Item Based Collaborative Filtering
  
  		17770 movies similarity index
  		vs. 480k users similarity index using User Based Collaborative Filtering


# Collaborative Filtering Approach

Two stages:
  
  Calculate the similarity index between items (movies)
    
		
		Euclidean Distance
		Correlation Coefficient
		Cosine Similarity Index
  
  Predict the rating using the similarity index
    
    	kNN – Average of k nearest neighbors
    	Similarity weighted average of ratings

# Challenges
	
	Very few explanatory variables. Except User ID, Movie ID & Date no other parameters available for prediction.
	
	Due to a very large amount of data, some computations required a long time. 
	
	Some other computations were not possible due to memory limitations.
	
	No in-built functions available in most statistical packages like Base SAS & R for collaborative filtering.

# Conclusion
	
	Item Based collaborative filtering with Cosine Similarity Index and Weighted average of it yielded 0.8875 RMSE.
			
			The above conclusion is based on results for top 10 most popular movies and Top 500 users.
