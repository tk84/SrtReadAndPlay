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
    @model.player.play
  end

  def registCallback
    Proc.new {|stime, etime|
      @model.play stime, time:etime
    }
  end
end

class MediaModel
  attr_accessor :player

  def initialize player
    @player = player
  end

  def self.makeModel url
    model = false

    if player = AVAudioPlayer.alloc.initWithContentsOfURL(url, error:nil)
      model = self.new player
    end

    return model
  end

  def play stime, time:etime
    @player.currentTime = stime
#    p @player.currentTime
#    @player.seekToTime CMTimeMakeWithSeconds(stime, 1)
  end
end
