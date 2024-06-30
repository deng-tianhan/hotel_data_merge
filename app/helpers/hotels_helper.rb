module HotelsHelper
  def prettify_amenities
    @amenities ||= @hotel.amenities.to_a
    output = {}
    categories = @amenities.map(&:category).uniq.sort_by{ |x| x || ''}
    categories.each do |key|
      output[key] = @amenities.filter{ |x| x.category == key }.map(&:name)
    end

    uncategorised_names = output.extract!(nil)[nil]
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

  def prettify_images
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
end
