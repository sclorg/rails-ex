# app/helpers/carousel_helper.rb

module CarouselHelper
  def carousel_for(images)
    Carousel.new(self, images).html
  end

  class Carousel
    def initialize(view, images)
      @view, @images = view, images
      @uid = SecureRandom.hex(6)
    end

    def html
      content = safe_join([indicators,"\n",slides,"\n",controls])
      options = {
        id: uid,
        class: 'carousel slide',
        data: {
          ride: 'carousel',
        }
      }
      content_tag(:div, content, options )
    end

    private

    attr_accessor :view, :images, :uid
    delegate :link_to, :content_tag, :image_tag, :safe_join, to: :view

    def indicators
      #items = images.count.times.map { |index| indicator_tag(index) }
      items = images.keys.count.times.map { |index| indicator_tag(index) }
      content_tag(:ol, safe_join(items), class: 'carousel-indicators')
    end

    def indicator_tag(index)
      options = {
        class: (index.zero? ? 'active' : ''),
        data: {
          target: uid,
          slide_to: index
        }
      }

      content_tag(:li, '', options)
    end

    def slides
      #items = images.map.with_index do |image, index|
      items = images.keys.map.with_index do |image, index|
        slide_tag(image, index.zero?, index)
      end
      options = {
        class: 'carousel-inner',
        role: 'listbox'
      }
      content_tag(:div, safe_join(items), options )
    end

    def slide_tag(image, is_active, index)
      options = {
        class: (is_active ? 'carousel-item active' : 'carousel-item'),
      }
      i_options = {
        class: "d-block img-fluid",
        style: "width:640px;height:310px",
      }
      items= []
      items.append(image_tag(image,i_options))
      items.append(caption_tag(image))
      #content_tag(:div, image_tag(image,i_options), options )
      content_tag(:div, safe_join(items), options )
    end

    def caption
      content_tag(:div, safe_join(items), options )
    end

    def caption_tag(image)
      options = {
        class: 'carousel-caption',
      }
      content_tag(:div, images[image], options )
    end

    def controls
      safe_join([control_tag('prev'), "\n", control_tag('next')])
    end

    def control_tag(direction)
      options = {
        class: "carousel-control-#{direction}",
        data: { slide: direction == 'prev' ? 'prev' : 'next' }
      }

      icon = content_tag(:span, '', class: "carousel-control-#{direction}-icon")
      control = link_to(icon, "##{uid}", options)
    end
  end
end
