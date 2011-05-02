#encoding: utf-8

module Ib
  module Web
    # #IButton Control Center
    # @todo Document this class
    class Control < Sinatra::Base
      include Db::Hw
      include Db::Persons
      use Assets::Compass
      use Assets::Coffee

      set :views, File.join(Ib::Config::WebConfig.sinatra_views, 'control')
      # @private GET '/'{{{2
      # Just returns the index.html.
      #
      # __Note:__<br />- don't forget we are in {Control} class
      # and because of this we get _/ctrl/index.html_
      # @see Ib::Web The Rack::Builder mapps
      get '/' do
        login_required
        haml :index, :layout => request.xhr? ? false : :layout
      end
      # @private GET '/:model/:page/list'{{{2
      # Route for listing tables content in record/row manner in 
      # browsers in browsers with _js enabled || disabled_.<br />
      # Instead of REST-full `GET /model` which returns a list of
      # all records, we have this route because of pagination
      # (Handling pagination server side).
      # @param :model conventionally == _Model.name.downcase.split('::')[-2..-1].join('\_')_
      # @param :page sets the OFFSET (page*LIMIT)
      get '/:model/:page/list' do |m,p|
        login_required
        obj = modelize(m)
        sort_desc = /Log::Access|Log::Error/
        ds = obj.name =~ sort_desc ? obj.order(:id.desc).paginate(p.to_i,25) : obj.paginate(p.to_i,25)
        haml :list, :layout => request.xhr? ? false : :layout, :locals => {:ds  => ds, :path => m}
      end
      # @private GET '/:model/:id'{{{2
      # Route for viewing content of one record in browsers
      # with _js enabled || disabled_.<br />Similar with REST-full
      # `GET /model/id` witch returns a record.
      # @param :model conventionally == _Model.name.downcase.split('::')[-2..-1].join('\_')_
      # @param :id Id of record
      get '/:model/:id' do |m,id|
        login_required
        obj = modelize(m)
        r = obj[id.to_i]
        haml :get, :layout => request.xhr? ? false : :layout, :locals => {:r  => r, :path => m}
      end
      # @private GET '/:model/:id/edit'{{{2
      # Route for editing content of one record in browsers
      # with _js enabled || disabled_.<br />Similar with REST-full
      # `GET /model/id/edit` witch returns a form for editing a record
      # @param :model conventionally == _Model.name.downcase.split('::')[-2..-1].join('\_')_
      # @param :id Id of record
      get '/:model/:id/edit' do |m,id|
        login_required
        obj = modelize(m)
        r = obj[id.to_i]
        haml :put, :layout => request.xhr? ? false : :layout, :locals => {:r  => r, :path => m}
      end
      # @private POST '/:model/:id/edit'{{{2
      # Route for saving edited content of one record in browsers with
      #  _js disabled_.<br />Similar with REST-full `POST /model/id/edit` witch
      # updates the selected record
      # @see Ib::Web::Control#PUT____model__id_ browsers with js
      #   enabled -> put '/:model/:id'
      # @param :model conventionally == _Model.name.downcase.split('::')[-2..-1].join('\_')_
      # @param :id Id of record
      post '/:model/:id/edit' do |m,id|
        login_required
        obj = modelize(m)
        r = obj[id.to_i]
        #r.update(params[:form])
      end
      # @private PUT '/:model/:id'{{{2
      # Route for saving edited content of one record in browsers with
      # _js enabled_.<br />Instead of REST-full `POST /model/id/edit` witch
      # updates the selected record, we use Sinatra's `put` verb, for same
      # result.
      # @see Ib::Web::Control#POST____model__id_edit_ in browsers with js
      #   disabled -> post '/:model/:id/edit'
      # @param :model conventionally == _Model.name.downcase.split('::')[-2..-1].join('\_')_
      # @param :id Id of record
      put '/:model/:id' do |m,id|
        login_required
        obj = modelize(m)
        r = obj[id.to_i]
        #r.update(params[:form])}
      end
      # @private GET '/:model/:id/delete'{{{2
      # Route for delete content of one record in browsers with
      # _js disabled_.<br />Similar with REST-full `GET /model/id/delete` witch
      # returns a form for deleting the record (may be simply a confirmation).
      #
      # __Note:__<br />- for browsers with _js enabled_ this route is identical but
      # in our case we may and we delete the record without confirmation.
      # @see Ib::Web::Control#DELETE____model__id_ in browsers with js
      #   enabled -> delete '/:model/:id'
      # @param :model conventionally == _Model.name.downcase.split('::')[-2..-1].join('\_')_
      # @param :id Id of record
      get '/:model/:id/delete' do |m,id|
        login_required
        obj = modelize(m)
        r = obj[id.to_i]
        haml :delete, :layout => request.xhr? ? false : :layout, :locals => {:r  => r, :path => m}
      end
      # @private POST '/:model/:id/delete'{{{2
      # Route for delete content of one record in browsers with
      # _js disabled_.<br />Similar with REST-full `POST /model/id/delete` witch
      # deletes the selected record.
      # @see Ib::Web::Control#DELETE____model__id_ in browsers with js
      #   enabled -> delete '/:model/:id'
      # @param :model conventionally == _Model.name.downcase.split('::')[-2..-1].join('\_')_
      # @param :id Id of record
      post '/:model/:id/delete' do |m,id|
        login_required
        obj = modelize(m)
        r = obj[id.to_i]
        r.destroy
      end
      # @private DELETE '/:model/:id'{{{2
      # Route for delete content of one record in browsers with
      # _js enabled_.<br />Instead of REST-full `POST /model/id/delete` witch
      # deletes the selected record, we use Sinatra's `delete` verb, for same
      # result.
      # @see Ib::Web::Control#POST____model__id_delete_ in browsers with js
      #   disabled -> post '/:model/:id/delete'
      # @param :model conventionally == _Model.name.downcase.split('::')[-2..-1].join('\_')_
      # @param :id Id of record
      delete '/:model/:id' do |m,id|
        login_required
        obj = modelize(m)
        r = obj[id.to_i]
        r.destroy
        flash[:msg] = {:msg => {:txt => I18n.t('mdl.delete', :data => r.model.name), :class => "info"}}.to_json
      end
      # @private GET '/:model/new'{{{2
      # Route for creating content for a new record in browsers with
      # _js enabled || disabled_.<br />Similar with REST-full `POST /model/new` witch
      # returns a form for creating a new record.
      # @param :model conventionally == _Model.name.downcase.split('::')[-2..-1].join('\_')_
      get '/:model/new' do |m|
        #login_required
        #obj = modelize(m)
        #r = obj[id.to_i]
        haml :post, :layout => request.xhr? ? false : :layout, :locals => {:r  => r, :path => m}
      end
      # @private POST '/:model/new'{{{2
      # Route for creating (inserting) the new record in browsers with
      # _js enabled || disabled_.<br />Similar with REST-full `POST /model/new` witch
      # returns the form again if the input is invalid, otherwise redirects
      # to the new resource.
      # @param :model conventionally == _Model.name.downcase.split('::')[-2..-1].join('\_')_
      post '/:model/new' do |m|
        #login_required
        #obj = modelize(m)
        #r = obj[id.to_i]
        #haml :edit, :layout => request.xhr? ? false : :layout, :locals => {:r  => r, :path => m}
      end
    end # Control
  end # Web
end # Ib
