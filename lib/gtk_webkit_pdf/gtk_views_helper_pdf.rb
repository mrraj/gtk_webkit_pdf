module GTK
  module ViewsHelper
    def self.root_path
      String === Rails.root ? Pathname.new(Rails.root) : Rails.root
    end

    def gtk_webkit_pdf_stylesheet_link_tag(*sources)
      css_dir  = ViewsHelper.root_path.join('app', 'assets', 'stylesheets')
      css_text = sources.collect { |source| "<style type='text/css'>#{File.read(css_dir.join(sources+'.css'))}</style>" }.join('\n')
      css_text.respond_to?(:html_safe) ? css_text.html_safe : css_text
    end

    def gtk_webkit_pdf_image_tag(img, options = {})
      image_tag("file:///#{ViewsHelper.root_path.join('app', 'assets', 'images', img)}", options)
    end

    def gtk_webkit_pdf_javascript_src_tag(jsfile, options = {})
      javascript_src_tag("file:///#{ViewsHelper.root_path.join('app', 'assets', 'javascripts', jsfile)}", options)
    end

    def gtk_webkit_pdf_javascript_include_tag(*sources)
      js_text = sources.collect { |source| gtk_webkit_pdf_javascript_src_tag(source, {}) }.join('\n')
      js_text.respond_to?(:html_safe) ? js_text.html_safe : js_text
    end
  end

  module AssetsHelper
    def gtk_webkit_pdf_stylesheet_link_tag(*sources)
      sources.collect { |source| "<style type='text/css'>#{read_asset(source+".css")}</style>" }.join('\n').html_safe
    end

    def gtk_webkit_pdf_image_tag(img, options={})
      image_tag("file://#{asset_pathname(img).to_s}", options)
    end

    def gtk_webkit_pdf_javascript_src_tag(jsfile, options={})
      javascript_include_tag("file:///#{asset_pathname(jsfile).to_s}", options)
    end

    def gtk_webkit_pdf_javascript_include_tag(*sources)
      sources.collect { |source| "<script type='text/javascript'>#{read_asset(source+".js")}</script>" }.join('\n').html_safe
    end

    private

    def asset_pathname(source)
      if Rails.configuration.assets.compile == false
        if ActionController::Base.asset_host
          # asset_path returns an absolute URL using asset_host if asset_host is set
          asset_path(source)
        else
          File.join(Rails.public_path, asset_path(source).sub(/\A#{Rails.application.config.action_controller.relative_url_root}/, ''))
        end
      else
        Rails.application.assets.find_asset(source).pathname
      end
    end

    def read_asset(source)
      if Rails.configuration.assets.compile == false
        if ActionController::Base.asset_host
          require 'open-uri'
          open(asset_pathname(source), 'r:UTF-8') {|f| f.read }
        else
          IO.read(asset_pathname(source))
        end
      else
        Rails.application.assets.find_asset(source).to_s
      end
    end
  end
end
