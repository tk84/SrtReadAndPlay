# -*- coding: utf-8 -*-
#
#  Media.rb
#  SrtReadAndPlay
#
#  Created by Hiroyuki Takahashi on 11/10/22.
#  Copyright 2011年 __MyCompanyName__. All rights reserved.
#

class MediaController < NSViewController
  attr_accessor :model

  def awakeFromNib
    # view.setURL @model.url
  end

end

class MediaModel
  def initialize url
    @url = url
  end

  def self.makeModel url
    model = self.new url
    return model
  end

  def url
    return @url
  end
end
