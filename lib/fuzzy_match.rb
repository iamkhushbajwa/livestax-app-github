class FuzzyMatch
  attr_reader :closest

  def initialize(original, comparators, opts={})
    @margin = opts['margin'] || 2
    @closest = proximate(original, comparators)
  end

  private

  def proximate(original, comparators)
    comparators.map{ |comparator| assign_cost(original, comparator) }
      .reject{ |costed| high_cost?(costed, original) }
      .sort { |a, b| sort_by_cost(a, b) }
      .map{ |costed| costed_key(costed) }
      .first || ''
  end

  def assign_cost(original, comparator)
    { comparator => DamerauLevenshtein.distance(original.downcase, comparator.downcase) }
  end

  def high_cost?(match, comparator)
    match.values[0] > (comparator.length - @margin)
  end

  def sort_by_cost(a, b)
    a.values[0] <=> b.values[0]
  end

  def costed_key(costed)
    costed.keys[0]
  end
end
