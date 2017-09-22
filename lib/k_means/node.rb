class Node

  class << self
    def create_nodes(data)
      nodes = []
      data.each do |position|
        nodes << new(position)
      end
      nodes
    end
  end

  attr_accessor :position, :best_distance, :closest_centroid

  def initialize(position)
    @position = position
  end

  def update_closest_centroid(centroids, feats, num_feats, ponderations_distances)
    # If we haven't processed this node we need to give it an initial centroid
    # so that we have something to compare distances against
    calculate_initial_centroid(centroids.first, feats, num_feats, ponderations_distances) unless @closest_centroid
    updated = false
    centroids.each_with_index do |centroid, centroid_index|
      # Check if they are in the same position
      if centroid.position == @position
        updated = update_attributes(centroid, 0.0)
        break
      end

      pond_distance = ClusterEngine.calcul_distance(self.position, centroid.position, ponderations_distances, feats, num_feats) # array of distances between all the features

      if pond_distance < self.best_distance
        updated = update_attributes(centroid, pond_distance)
      end
    end

    updated == true ? 1 : 0
  end

  def reset!
    @closest_centroid = nil
    @best_distance    = nil
  end

  private

  def update_attributes(closest_centroid, best_distance)
    @closest_centroid, @best_distance = closest_centroid, best_distance
    true
  end

  def calculate_initial_centroid(centroid, feats, num_feats, ponderations_distances)
    @closest_centroid = centroid
    distance =  ClusterEngine.calcul_distance(self.position, centroid.position, ponderations_distances, feats, num_feats) # cette distance est non pondérée 
    @best_distance = distance
  end

end
