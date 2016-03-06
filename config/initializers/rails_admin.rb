RailsAdmin.config do |config|

  ### Popular gems integration

  ## == Devise ==
  # config.authenticate_with do
  #   warden.authenticate! scope: :user
  # end
  # config.current_user_method(&:current_user)

  ## == Cancan ==
  # config.authorize_with :cancan

  ## == Pundit ==
  # config.authorize_with :pundit

  ## == PaperTrail ==
  # config.audit_with :paper_trail, 'User', 'PaperTrail::Version' # PaperTrail >= 3.0.0

  ### More at https://github.com/sferik/rails_admin/wiki/Base-configuration

  config.actions do
    dashboard                     # mandatory
    index                         # mandatory
    new
    export
    bulk_delete
    show
    edit
    delete
    show_in_app

    ## With an audit adapter, you can add:
    # history_index
    # history_show
  end

  config.navigation_static_links = {
    'The Workers' => '/admin/theworkers'
  }

  config.total_columns_width = 9999999
  config.default_items_per_page = 20

  config.model 'Article' do
    list do
      field :_id do
        column_width 200
      end
      field :created_at do
        column_width 200
      end
      field :updated_at do
        column_width 200
      end
      field :published_at do
        column_width 200
      end
      field :image_url do
        column_width 260
        pretty_value do
          bindings[:view].content_tag(:a, { href: value, target: "_blank", title: value }) do
            bindings[:view].tag(:img, { :src => value, style: "max-height:160px; max-width:260px;" })
          end
        end
      end
      field :title do
        column_width 400
      end
      field :url do
        column_width 400
        pretty_value do
          bindings[:view].content_tag(:a, value, { href: value, target: "_blank", title: value })
        end
      end
      field :categories do
        column_width 200
      end
      field :source do
        column_width 200
      end
      field :sources do
        column_width 200
      end
      field :description do
        column_width 400
        pretty_value do
          bindings[:view].content_tag(:div, value, { title: value, style: 'white-space:normal;' })
        end
      end
      field :author do
        column_width 200
      end
      field :summary do
        column_width 200
        pretty_value do
          bindings[:view].content_tag(:div, value, { title: value, style: 'white-space:normal; max-height:160px; overflow:hidden;' })
        end
      end
      field :points do
        column_width 100
      end
      field :comments do
        column_width 100
      end
      field :normalized_popularity do
        column_width 200
      end
    end
  end
end
