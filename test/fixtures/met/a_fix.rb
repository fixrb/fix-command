# frozen_string_literal: true

require "fix"

Fix :A do
  on :size do
    it MUST eq 1
  end
end

exit(Fix[:A].test { [1] })
