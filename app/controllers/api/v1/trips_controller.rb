module Api
  module V1
    class TripsController < Api::V1::ApiController

      def status_from_token
        #Get the itineraries
        trip_token = params[:trip_token]
        agency_token = params[:agency_token] || nil
        trip = Trip.where(token: trip_token, agency_token: agency_token).first
        get_trip_status trip

      end

      def details_from_token
        trip_token = params[:trip_token]
        agency_token = params[:agency_token] || nil
        trip = Trip.where(token: trip_token, agency_token: agency_token).first
        get_trip_details trip
      end

      def status
        trip_id = params[:id].to_i
        trip = Trip.find(trip_id)
        get_trip_status trip
      end

      def details
        trip_id = params[:id].to_i
        trip = Trip.find(trip_id)
        get_trip_details trip
      end


      def get_trip_status trip

        if trip
          hash = {trip_status_report: {trip_token: trip.token, trip_id: trip.id, code: trip.status[:code], description: trip.status[:description]}}
        else
          hash = {trip_status_report: {trip_token: nil, trip_id: nil, code: "404", description: "Trip not found."}}
        end

        respond_with hash

      end

      def get_trip_details trip

        # This is a stub.
        # More details will be added as-needed.
        if trip
          hash = {status: {code: trip.status[:code], description: trip.status[:description]}, details: trip}
        else
          hash = {status: {code: '404', description: 'Trip Not Found'}, details: nil}
        end
        respond_with hash

      end

      def list
        trips_array = []
        @traveler.trips.selected.order(created_at: :desc)[0..19].each do |trip|
          trip_hash =  trip.attributes
          trip_hash[:from_place] = trip.from_place.nil? ? '' : trip.from_place.name
          trip_hash[:to_place] = trip.to_place.nil? ? ' ' : trip.to_place.name
          itineraries_array = []
          trip.selected_itineraries.each do |itinerary|
            itinerary_hash = itinerary.attributes
            mode = itinerary.mode
            itinerary_hash[:mode] = {name: TranslationEngine.translate_text(mode.name), code: mode.code}

            itinerary_hash[:segment_index] = itinerary.trip_part.sequence
            itinerary_hash[:start_location] = itinerary.trip_part.from_trip_place.build_place_details_hash
            itinerary_hash[:end_location] = itinerary.trip_part.to_trip_place.build_place_details_hash
            itinerary_hash[:prebooking_questions] = itinerary.prebooking_questions
            itinerary_hash[:bookable] = itinerary.is_bookable?
            itinerary_hash[:confirmation_id] = itinerary.booking_confirmation

            if itinerary.service
              itinerary_hash[:service_name] = itinerary.service.name
            else
              itinerary_hash[:service_name] = ""
            end

            if itinerary.discounts
              itinerary_hash[:discounts] = JSON.parse(itinerary.discounts)
            end

            if itinerary.legs
              itinerary_hash[:json_legs] = (YAML.load(itinerary.legs)).as_json
            else
              itinerary_hash[:json_legs] = nil
            end

            if itinerary.negotiated_pu_time.nil?
              wait_start = nil
              wait_end = nil
            else
              #Create +/- fifteen minute window around pickup time
              wait_start = (itinerary.negotiated_pu_time - 15*60).iso8601
              wait_end = (itinerary.negotiated_pu_time + 15*60).iso8601
            end

            itinerary_hash[:wait_start] =  wait_start
            itinerary_hash[:wait_end] = wait_end
            itinerary_hash[:arrival] = itinerary.negotiated_do_time.nil? ? nil : itinerary.negotiated_do_time.iso8601


            itineraries_array.append(itinerary_hash)

          end
          trip_hash[:itineraries] = itineraries_array
          trips_array.append(trip_hash)
        end
        hash = {trips: trips_array}
        respond_with hash
      end

      def index
        list
      end
    end
  end
end
