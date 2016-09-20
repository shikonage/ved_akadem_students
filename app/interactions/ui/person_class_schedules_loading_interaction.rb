module Ui
  class PersonClassSchedulesLoadingInteraction < BaseInteraction
    include ClassSchedulesLoadable

    def init
      # TODO: replace this when ElasticSearch appears
      # TODO: injection is possible!
      @class_schedules = ClassScheduleWithPeople.personal_schedule(user.id, params[:page])
    end
  end
end
