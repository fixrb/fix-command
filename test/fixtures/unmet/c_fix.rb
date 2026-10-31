# frozen_string_literal: true

require "fix"

Fix :C do
  on :size do
    it MUST eq 2
  end
end

exit(Fix[:C].test { [1] })
