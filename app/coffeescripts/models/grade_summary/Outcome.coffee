define [
  'i18n!outcomes'
  'underscore'
  'Backbone'
  'compiled/models/Outcome'
  'timezone'
], (I18n, _, {Model, Collection}, Outcome, tz) ->

  GradeSummary = {}
  class GradeSummary.Outcome extends Outcome
    initialize: ->
      super
      @set 'friendly_name', @get('display_name') || @get('title')
      @set 'hover_name', (@get('title') if @get('display_name'))
      @set 'scaled_score', (@scaledScore())

    parse: (response) ->
      super _.extend(response, {
        submitted_or_assessed_at: tz.parse(response.submitted_or_assessed_at),
        question_bank_result: response.links?.alignment?.includes("assessment_question_bank")
      })

    status: ->
      if @scoreDefined()
        score = @score()
        mastery = @get('mastery_points')
        if score >= mastery + (mastery / 2)
          'exceeds'
        else if score >= mastery
          'mastery'
        else if score >= mastery / 2
          'near'
        else
          'remedial'
      else
        'undefined'

    statusTooltip: ->
      {
        'undefined': I18n.t('Unstarted')
        'remedial': I18n.t('Well Below Mastery')
        'near': I18n.t('Near Mastery')
        'mastery': I18n.t('Meets Mastery')
        'exceeds': I18n.t('Exceeds Mastery')
      }[@status()]

    roundedScore: ->
      if @scoreDefined()
        Math.round(@score() * 100.0) / 100.0
      else
        null

    scoreDefined: ->
      _.isNumber(@get('score'))

    scaledScore: ->
      is_aggregate_score = @get('question_bank_result')
      return unless @scoreDefined() && is_aggregate_score
      @get('percent') * @get('points_possible')

    score: ->
      @get('scaled_score') || @get('score')

    percentProgress: ->
      return 0 unless @scoreDefined()
      if @get('percent')
        @get('percent') * 100
      else
        @score()/@get('points_possible') * 100

    masteryPercent: ->
      @get('mastery_points')/@get('points_possible') * 100

    toJSON: ->
      _.extend super,
        status: @status()
        statusTooltip: @statusTooltip()
        roundedScore: @roundedScore()
        scoreDefined: @scoreDefined()
        percentProgress: @percentProgress()
        masteryPercent: @masteryPercent()
