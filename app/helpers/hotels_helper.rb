module HotelsHelper
  def prettify_hotel(hotel = @hotel)
    output = hotel.attributes
    output.extract!('id', 'created_at', 'updated_at')
    output.delete('metadata')&.each { |k, v| output[k] = v }

    key_mapping = {
      identifier: :id, destination: :destination_id,
      latitude: :lat, longitude: :lng,
    }
    key_mapping.each { |k, v| output[v.to_s] = output.delete(k.to_s) }

    location = output.extract!('address','city','country','lat','lng')
    postal_code = output.extract!('postal_code').values.last
    if postal_code && location['address'].exclude?(postal_code)
      location['address'] = location['address'] + ', ' + postal_code
    end
    output['location'] = location.compact

    output['amenities'] = prettify_amenities(hotel)
    output['images'] = prettify_images(hotel)

    return output
  end

  def prettify_amenities(hotel = @hotel)
    amenities = hotel.amenities.to_a
    output = {}
    categories = amenities.map(&:category).uniq.sort_by{ |x| x || '' }
    categories.each do |key|
      output[key] = amenities.filter{ |x| x.category == key }.map(&:name)
    end

    uncategorised_names = output.delete('')
    if uncategorised_names.present?
      categorised_names = output.values.flatten.join(",\n")
      uncategorised_names
        .filter{ |x| categorised_names.include?(x) }
        .each { |x| uncategorised_names.delete(x) }
    end
    if uncategorised_names.present?
      output['general'] ||= []
      output['general'].concat(uncategorised_names)
    end

    return output
  end

  def prettify_images(hotel = @hotel)
    images = hotel.images.to_a
    output = {}
    categories = images.map(&:category).uniq
    categories.each do |key|
      output[key] =
        images
          .filter{ |x| x.category == key }
          .map{ |x| { 'description' => x.caption, "link" => x.link } }
    end
    return output
  end

  def sort_images
    @images ||= @hotel.images
    unify_categories(@images)
    @images.sort_by{ |x| pretty_string(x) }
  end

  def prev_hotel_id
    @hotel_ids ||= Hotel.select(:id).map(&:id).sort
    current_index = @hotel_ids.index(@hotel.id)

    if current_index > 0
      @hotel_ids[current_index - 1]
    else
      nil
    end
  end

  def next_hotel_id
    @hotel_ids ||= Hotel.select(:id).map(&:id).sort
    current_index = @hotel_ids.index(@hotel.id)

    if current_index < @hotel_ids.length
      @hotel_ids[current_index + 1]
    else
      nil
    end
  end

  private

  def pretty_string(image)
    [
      image.category.titleize,
      image.caption,
    ]
  end

  def unify_categories(images)
    images.each do |a|
      images.each do |b|
        if a != b && a.category != b.category && a.caption == b.caption
          a.category = b.category
        end
      end
    end
  end

  def remove_broken_images
    @images = @hotel.images.to_a
    images_to_remove =
      @hotel.images.filter do |image|
        result = Net::HTTP.get_response(URI.parse(image.url))
        !result.is_a?(Net::HTTPSuccess)
      end
    @images -= images_to_remove
    return @images
  end
end
