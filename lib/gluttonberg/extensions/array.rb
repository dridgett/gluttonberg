class Array
  if !respond_to?(:pluck)
    # Accepts a block and returns the first element for which the block
    # returns true.
    def pluck(&blk)
      i = 0
      while i < length
        return self[i] if blk.call(self[i])
        i += 1
      end
    end
  end
end
