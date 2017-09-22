require 'ext/object'

class KMeans

  attr_reader :centroids, :nodes, :feats, :ponderations_distances, :initialisation_indexes, :num_feats

  def initialize(data, options={})
    @initialisation_indexes = options[:initialisation_indexes]
    @nodes = Node.create_nodes(data)
    nbr_centroids = options[:centroids]
    @centroids = Array.new(){Centroid}
    
    initialisation_indexes.each do |ind|
      @centroids << Centroid.new(data[ind])
    end
    @feats = options[:features]
    @num_feats = options[:num_feats]
    @ponderations_distances = options[:ponderations_distances]
    @verbose = options[:verbose]

    perform_cluster_process
  end

  def inspect
    @centroid_pockets.inspect
  end

  def view
    @centroid_pockets
  end

  private

  def perform_cluster_process
    iterations, updates = 0, 1
    while updates > 0 && iterations < 500
      puts "iteration number : #{iterations}"
      iterations += 1
      verbose_message("Iteration #{iterations}")
      updates = 0
      updates += update_nodes
      reposition_centroids
    end
    place_nodes_into_pockets
  end

  # This creates an array of arrays
  # Each internal array represents a centroid
  # and each in the array represents the nodes index
  def place_nodes_into_pockets
    centroid_pockets = Array.new(@centroids.size) {[]}
    @centroids.each_with_index do |centroid, centroid_index|
      @nodes.each_with_index do |node, node_index|
        if node.closest_centroid == centroid
          centroid_pockets[centroid_index] << node_index
        end
      end
    end
    @centroid_pockets = centroid_pockets
  end

  def update_nodes
    sum = 0
    @nodes.each_with_index do |node,node_index|
      sum += node.update_closest_centroid(@centroids, feats, num_feats, ponderations_distances)
    end
    sum
  end

  def reposition_centroids
    centroid_positions = @centroids.map(&:position)
    @centroids.each do |centroid|
      nodes = []
      @nodes.each {|n| nodes << n if n.closest_centroid == centroid}
      centroid.reposition(nodes, centroid_positions, @feats, @num_feats)
    end
  end

  def verbose_message(message)
    puts message if @verbose
  end

end
