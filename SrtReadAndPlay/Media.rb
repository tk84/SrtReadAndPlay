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
#    @model.player.play
  end

  def stop
    @model.player.stop
  end

  def finalize
    super
    p 'MediaController finalize'
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

    asset = AVAsset.assetWithURL url
    if asset.isPlayable
      player = AVPlayer.playerWithPlayerItem AVPlayerItem.playerItemWithAsset asset
      model = self.new player
    end

    return model
  end

  def play stime, time:etime

    @player.pause
    @player.seekToTime CMTimeMakeWithSeconds(stime, 1)

    # Timer.setTimeout 1000 {
    #   @player.pause
    # }

    # p stime
    # p etime
    # p CMTimeMakeWithSeconds(stime, 1)
    # p CMTimeMakeWithSeconds(etime, 1)


    times = [NSValue.valueWithCMTime(CMTimeMakeWithSeconds(etime, 1))]
    @player.removeTimeObserver @timeObserverToken if @timeObserverToken
    @timeObserverToken = @player.addBoundaryTimeObserverForTimes times, queue:nil, usingBlock:Proc.new {
      @player.pause
      puts @player.currentTime
      puts count
      count += 1
    }

    @player.play

  end
end
