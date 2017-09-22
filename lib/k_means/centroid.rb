class Centroid
  
  class << self
    def create_centroids(amount, nodes, initialisation_indexes)

      initialisation_indexes.each do |ind|
        position = Array.new(4){0} 
        position = nodes[ind].position
        Centroid.new(position)
      end
    end

  end
  
  
  attr_accessor :position
  
  def initialize(position)
    @position = position
  end

  def reposition_OKNS (common_OKNS)

    if common_OKNS.count == 1
      return common_OKNS[0]
    else
      sum_dist = Array.new(common_OKNS.count){0.0}
      for i in (0..(common_OKNS.count-1))
        for j in (0..(common_OKNS.count-1))
          sum_dist[i] += ClusterEngine.categorical_distance(common_OKNS[i],common_OKNS[j])
        end
      end
      min_dist_index = sum_dist.each_with_index.min[1]
      return common_OKNS[min_dist_index]
    end
  end
  
  def reposition_scores(scores_hashes)
    dist_from_all_samples = Array.new(scores_hashes.count){0.0}
    for i in (0..scores_hashes.count-1)
      for j in (0..scores_hashes.count - 1)
        dist_from_all_samples[i] += ClusterEngine.between_scores_distance(scores_hashes[i], scores_hashes[j])
      end
    end
    min_dist_index = dist_from_all_samples.each_with_index.min[1]
    return scores_hashes[min_dist_index]

  end

  # Finds the average distance of all the nodes assigned to
  # the centroid and then moves the centroid to that position
  def reposition(nodes, centroids, features_names, num_features_names)

    return if nodes.empty?
    averages = [0.0] * nodes[0].position.size
    ucom_OKNs = []
    nodes_positions = nodes.map{|node| node.position}

    features_names.each_with_index do |feat, index|
      
      # if the feature is a categorical array
      if feat == "urOKNs"
        ucom_OKNs = nodes_positions.map{|c| c[index]} 
        averages[index] = reposition_OKNS(ucom_OKNs)
      
      # if the feature is a numeric array
      elsif feat == "scores" 
        averages[index] = reposition_scores(nodes_positions.map{|c| c[index]})
    
      # if the feature is a single numeric value
      elsif ClusterEngine.array_contains_elet(num_features_names, feat) # single numeric features
        averages[index] = nodes_positions.map{|c| c[index]}.inject(:+).to_f/nodes.count

      # if the feature is a single categoric value
      else 
          averages[index] = nodes_positions.map{|c| c[index]}.each_with_object(Hash.new(0)){|str, hsh| hsh[str] += 1}.sort_by{|key, value| value}.last[0] 
      end
    end

    @position = averages
  end
end

