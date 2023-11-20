defmodule KartVids.SeasonAnalyzerFixture do
  def league_races() do
    [
      %KartVids.Races.Race{
        id: 22432,
        name: "12 Lap Junior - Group",
        external_race_id: "212614",
        started_at: ~U[2023-11-19 12:32:00Z],
        ended_at: ~U[2023-11-19 12:36:00Z],
        league?: false,
        league_type: :none,
        location_id: 1,
        season_id: 2,
        racers: [
          %KartVids.Races.Racer{
            id: 110_027,
            average_lap: 22.278333333333332,
            fastest_lap: 21.722,
            kart_num: 43,
            nickname: "Emmitt",
            photo: "https://aisdulles.clubspeedtiming.com/CustomerPictures/1519776.jpg",
            position: 3,
            external_racer_id: "1519776",
            race_by: :laps,
            win_by: :laptime,
            race_id: 22432,
            racer_profile_id: 125,
            location_id: 1,
            laps: [
              %KartVids.Races.Racer.Lap{
                lap_time: 22.028,
                amb_time: 4_294_007.352,
                lap_number: 1
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 22.178,
                amb_time: 4_294_029.53,
                lap_number: 2
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 22.642,
                amb_time: 4_294_052.172,
                lap_number: 3
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 22.939,
                amb_time: 4_294_075.111,
                lap_number: 4
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 22.232,
                amb_time: 4_294_097.343,
                lap_number: 5
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 22.487,
                amb_time: 4_294_119.83,
                lap_number: 6
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 21.899,
                amb_time: 4_294_141.729,
                lap_number: 7
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 21.722,
                amb_time: 4_294_163.451,
                lap_number: 8
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 23.0,
                amb_time: 4_294_186.451,
                lap_number: 9
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 22.157,
                amb_time: 4_294_208.608,
                lap_number: 10
              }
            ],
            inserted_at: ~N[2023-11-19 12:36:53],
            updated_at: ~N[2023-11-19 12:36:53]
          },
          %KartVids.Races.Racer{
            id: 110_029,
            average_lap: 21.868666666666666,
            fastest_lap: 20.665,
            kart_num: 48,
            nickname: "Milo AE86",
            photo: "https://aisdulles.clubspeedtiming.com/CustomerPictures/8176814.jpg",
            position: 1,
            external_racer_id: "8176814",
            race_by: :laps,
            win_by: :laptime,
            race_id: 22432,
            racer_profile_id: 33829,
            location_id: 1,
            laps: [
              %KartVids.Races.Racer.Lap{
                lap_time: 23.748,
                amb_time: 4_294_018.352,
                lap_number: 1
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 20.722,
                amb_time: 4_294_039.074,
                lap_number: 2
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 22.824,
                amb_time: 4_294_061.898,
                lap_number: 3
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 21.093,
                amb_time: 4_294_082.991,
                lap_number: 4
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 20.779,
                amb_time: 4_294_103.77,
                lap_number: 5
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 20.665,
                amb_time: 4_294_124.435,
                lap_number: 6
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 21.889,
                amb_time: 4_294_146.324,
                lap_number: 7
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 20.717,
                amb_time: 4_294_167.041,
                lap_number: 8
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 21.399,
                amb_time: 4_294_188.44,
                lap_number: 9
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 21.092,
                amb_time: 4_294_209.532,
                lap_number: 10
              }
            ],
            inserted_at: ~N[2023-11-19 12:36:53],
            updated_at: ~N[2023-11-19 12:36:53]
          },
          %KartVids.Races.Racer{
            id: 110_026,
            average_lap: 22.5185,
            fastest_lap: 22.156,
            kart_num: 41,
            nickname: "Jacob",
            photo: "https://aisdulles.clubspeedtiming.com/CustomerPictures/11234123.jpg",
            position: 4,
            external_racer_id: "11234123",
            race_by: :laps,
            win_by: :laptime,
            race_id: 22432,
            racer_profile_id: 15295,
            location_id: 1,
            laps: [
              %KartVids.Races.Racer.Lap{
                lap_time: 22.279,
                amb_time: 4_294_019.96,
                lap_number: 1
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 22.347,
                amb_time: 4_294_042.307,
                lap_number: 2
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 22.255,
                amb_time: 4_294_064.562,
                lap_number: 3
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 23.349,
                amb_time: 4_294_087.911,
                lap_number: 4
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 22.432,
                amb_time: 4_294_110.343,
                lap_number: 5
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 22.156,
                amb_time: 4_294_132.499,
                lap_number: 6
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 22.602,
                amb_time: 4_294_155.101,
                lap_number: 7
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 23.085,
                amb_time: 4_294_178.186,
                lap_number: 8
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 22.674,
                amb_time: 4_294_200.86,
                lap_number: 9
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 22.485,
                amb_time: 4_294_223.345,
                lap_number: 10
              }
            ],
            inserted_at: ~N[2023-11-19 12:36:53],
            updated_at: ~N[2023-11-19 12:36:53]
          },
          %KartVids.Races.Racer{
            id: 110_025,
            average_lap: 22.681333333333328,
            fastest_lap: 22.31,
            kart_num: 40,
            nickname: "Paul",
            photo: "https://aisdulles.clubspeedtiming.com/CustomerPictures/11233287.jpg",
            position: 5,
            external_racer_id: "11233287",
            race_by: :laps,
            win_by: :laptime,
            race_id: 22432,
            racer_profile_id: 18997,
            location_id: 1,
            laps: [
              %KartVids.Races.Racer.Lap{
                lap_time: 22.368,
                amb_time: 4_294_015.748,
                lap_number: 1
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 22.995,
                amb_time: 4_294_038.743,
                lap_number: 2
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 23.121,
                amb_time: 4_294_061.864,
                lap_number: 3
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 22.784,
                amb_time: 4_294_084.648,
                lap_number: 4
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 22.31,
                amb_time: 4_294_106.958,
                lap_number: 5
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 22.892,
                amb_time: 4_294_129.85,
                lap_number: 6
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 22.495,
                amb_time: 4_294_152.345,
                lap_number: 7
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 22.546,
                amb_time: 4_294_174.891,
                lap_number: 8
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 22.731,
                amb_time: 4_294_197.622,
                lap_number: 9
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 23.198,
                amb_time: 4_294_220.82,
                lap_number: 10
              }
            ],
            inserted_at: ~N[2023-11-19 12:36:53],
            updated_at: ~N[2023-11-19 12:36:53]
          },
          %KartVids.Races.Racer{
            id: 110_028,
            average_lap: 22.065249999999995,
            fastest_lap: 21.562,
            kart_num: 47,
            nickname: "Danny Jauregui",
            photo: "https://aisdulles.clubspeedtiming.com/CustomerPictures/11258317.jpg",
            position: 2,
            external_racer_id: "11258317",
            race_by: :laps,
            win_by: :laptime,
            race_id: 22432,
            racer_profile_id: 10249,
            location_id: 1,
            laps: [
              %KartVids.Races.Racer.Lap{
                lap_time: 21.972,
                amb_time: 4_294_010.299,
                lap_number: 1
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 21.6,
                amb_time: 4_294_031.899,
                lap_number: 2
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 22.171,
                amb_time: 4_294_054.07,
                lap_number: 3
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 21.985,
                amb_time: 4_294_076.055,
                lap_number: 4
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 22.747,
                amb_time: 4_294_098.802,
                lap_number: 5
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 21.562,
                amb_time: 4_294_120.364,
                lap_number: 6
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 21.814,
                amb_time: 4_294_142.178,
                lap_number: 7
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 21.655,
                amb_time: 4_294_163.833,
                lap_number: 8
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 23.534,
                amb_time: 4_294_187.367,
                lap_number: 9
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 21.799,
                amb_time: 4_294_209.166,
                lap_number: 10
              }
            ],
            inserted_at: ~N[2023-11-19 12:36:53],
            updated_at: ~N[2023-11-19 12:36:53]
          },
          %KartVids.Races.Racer{
            id: 110_024,
            average_lap: 24.56090909090909,
            fastest_lap: 22.438,
            kart_num: 31,
            nickname: "Bryson",
            photo: "https://aisdulles.clubspeedtiming.com/CustomerPictures/11274283.jpg",
            position: 6,
            external_racer_id: "11274283",
            race_by: :laps,
            win_by: :laptime,
            race_id: 22432,
            racer_profile_id: 21560,
            location_id: 1,
            laps: [
              %KartVids.Races.Racer.Lap{
                lap_time: 24.95,
                amb_time: 4_294_028.783,
                lap_number: 1
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 22.889,
                amb_time: 4_294_051.672,
                lap_number: 2
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 24.091,
                amb_time: 4_294_075.763,
                lap_number: 3
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 25.146,
                amb_time: 4_294_100.909,
                lap_number: 4
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 23.281,
                amb_time: 4_294_124.19,
                lap_number: 5
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 26.071,
                amb_time: 4_294_150.261,
                lap_number: 6
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 28.375,
                amb_time: 4_294_178.636,
                lap_number: 7
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 23.029,
                amb_time: 4_294_201.665,
                lap_number: 8
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 22.438,
                amb_time: 4_294_224.103,
                lap_number: 9
              }
            ],
            inserted_at: ~N[2023-11-19 12:36:53],
            updated_at: ~N[2023-11-19 12:36:53]
          },
          %KartVids.Races.Racer{
            id: 110_030,
            average_lap: 24.566090909090907,
            fastest_lap: 23.158,
            kart_num: 49,
            nickname: "Han",
            photo: "https://aisdulles.clubspeedtiming.com/CustomerPictures/11233289.jpg",
            position: 7,
            external_racer_id: "11233289",
            race_by: :laps,
            win_by: :laptime,
            race_id: 22432,
            racer_profile_id: 19003,
            location_id: 1,
            laps: [
              %KartVids.Races.Racer.Lap{
                lap_time: 23.158,
                amb_time: 4_294_014.663,
                lap_number: 1
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 23.871,
                amb_time: 4_294_038.534,
                lap_number: 2
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 25.627,
                amb_time: 4_294_064.161,
                lap_number: 3
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 23.671,
                amb_time: 4_294_087.832,
                lap_number: 4
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 24.456,
                amb_time: 4_294_112.288,
                lap_number: 5
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 24.402,
                amb_time: 4_294_136.69,
                lap_number: 6
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 25.056,
                amb_time: 4_294_161.746,
                lap_number: 7
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 27.652,
                amb_time: 4_294_189.398,
                lap_number: 8
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 26.018,
                amb_time: 4_294_215.416,
                lap_number: 9
              }
            ],
            inserted_at: ~N[2023-11-19 12:36:53],
            updated_at: ~N[2023-11-19 12:36:53]
          }
        ],
        inserted_at: ~N[2023-11-19 12:36:53],
        updated_at: ~N[2023-11-19 12:38:54]
      },
      %KartVids.Races.Race{
        id: 22433,
        name: "12 Lap Junior - Group",
        external_race_id: "212611",
        started_at: ~U[2023-11-19 12:42:00Z],
        ended_at: ~U[2023-11-19 12:48:00Z],
        league?: false,
        league_type: :none,
        location_id: 1,
        season_id: 2,
        racers: [
          %KartVids.Races.Racer{
            id: 110_031,
            average_lap: 24.095428571428563,
            fastest_lap: 22.889,
            kart_num: 32,
            nickname: "Speedy Turtle",
            photo: "https://aisdulles.clubspeedtiming.com/CustomerPictures/8182382.jpg",
            position: 3,
            external_racer_id: "8182382",
            race_by: :laps,
            win_by: :laptime,
            race_id: 22433,
            racer_profile_id: 22375,
            location_id: 1,
            laps: [
              %KartVids.Races.Racer.Lap{
                lap_time: 25.31,
                amb_time: 4_294_647.879,
                lap_number: 1
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 22.889,
                amb_time: 4_294_670.768,
                lap_number: 2
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 23.476,
                amb_time: 4_294_694.244,
                lap_number: 3
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 23.801,
                amb_time: 4_294_718.045,
                lap_number: 4
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 24.153,
                amb_time: 4_294_742.198,
                lap_number: 5
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 24.07,
                amb_time: 4_294_766.268,
                lap_number: 6
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 23.605,
                amb_time: 4_294_789.873,
                lap_number: 7
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 23.998,
                amb_time: 4_294_813.871,
                lap_number: 8
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 24.4,
                amb_time: 4_294_838.271,
                lap_number: 9
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 23.624,
                amb_time: 4_294_861.895,
                lap_number: 10
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 24.419,
                amb_time: 4_294_886.314,
                lap_number: 11
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 22.971,
                amb_time: 4_294_909.285,
                lap_number: 12
              }
            ],
            inserted_at: ~N[2023-11-19 12:48:17],
            updated_at: ~N[2023-11-19 12:48:17]
          },
          %KartVids.Races.Racer{
            id: 110_033,
            average_lap: 24.211214285714288,
            fastest_lap: 23.514,
            kart_num: 53,
            nickname: "Austin",
            photo: "https://aisdulles.clubspeedtiming.com/CustomerPictures/11199007.jpg",
            position: 4,
            external_racer_id: "11199007",
            race_by: :laps,
            win_by: :laptime,
            race_id: 22433,
            racer_profile_id: 12532,
            location_id: 1,
            laps: [
              %KartVids.Races.Racer.Lap{
                lap_time: 25.329,
                amb_time: 4_294_645.7,
                lap_number: 1
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 23.9,
                amb_time: 4_294_669.6,
                lap_number: 2
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 23.86,
                amb_time: 4_294_693.46,
                lap_number: 3
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 23.75,
                amb_time: 4_294_717.21,
                lap_number: 4
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 24.295,
                amb_time: 4_294_741.505,
                lap_number: 5
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 23.959,
                amb_time: 4_294_765.464,
                lap_number: 6
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 23.576,
                amb_time: 4_294_789.04,
                lap_number: 7
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 24.111,
                amb_time: 4_294_813.151,
                lap_number: 8
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 24.162,
                amb_time: 4_294_837.313,
                lap_number: 9
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 24.082,
                amb_time: 4_294_861.395,
                lap_number: 10
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 23.514,
                amb_time: 4_294_884.909,
                lap_number: 11
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 23.761,
                amb_time: 4_294_908.67,
                lap_number: 12
              }
            ],
            inserted_at: ~N[2023-11-19 12:48:18],
            updated_at: ~N[2023-11-19 12:48:18]
          },
          %KartVids.Races.Racer{
            id: 110_034,
            average_lap: 23.402000000000005,
            fastest_lap: 22.655,
            kart_num: 58,
            nickname: "Bentlee",
            photo: "https://aisdulles.clubspeedtiming.com/CustomerPictures/11187444.jpg",
            position: 2,
            external_racer_id: "11187444",
            race_by: :laps,
            win_by: :laptime,
            race_id: 22433,
            racer_profile_id: 8211,
            location_id: 1,
            laps: [
              %KartVids.Races.Racer.Lap{
                lap_time: 23.303,
                amb_time: 4_294_638.364,
                lap_number: 1
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 22.655,
                amb_time: 4_294_661.019,
                lap_number: 2
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 23.061,
                amb_time: 4_294_684.08,
                lap_number: 3
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 23.202,
                amb_time: 4_294_707.282,
                lap_number: 4
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 23.169,
                amb_time: 4_294_730.451,
                lap_number: 5
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 22.989,
                amb_time: 4_294_753.44,
                lap_number: 6
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 23.419,
                amb_time: 4_294_776.859,
                lap_number: 7
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 23.12,
                amb_time: 4_294_799.979,
                lap_number: 8
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 23.791,
                amb_time: 4_294_823.77,
                lap_number: 9
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 23.59,
                amb_time: 4_294_847.36,
                lap_number: 10
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 24.793,
                amb_time: 4_294_872.153,
                lap_number: 11
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 23.93,
                amb_time: 4_294_896.083,
                lap_number: 12
              }
            ],
            inserted_at: ~N[2023-11-19 12:48:18],
            updated_at: ~N[2023-11-19 12:48:18]
          },
          %KartVids.Races.Racer{
            id: 110_032,
            average_lap: 23.003714285714285,
            fastest_lap: 22.584,
            kart_num: 46,
            nickname: "Sebastian Zieglar",
            photo: "https://aisdulles.clubspeedtiming.com/CustomerPictures/11213892.jpg",
            position: 1,
            external_racer_id: "11213892",
            race_by: :laps,
            win_by: :laptime,
            race_id: 22433,
            racer_profile_id: 199,
            location_id: 1,
            laps: [
              %KartVids.Races.Racer.Lap{
                lap_time: 23.424,
                amb_time: 4_294_641.347,
                lap_number: 1
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 22.615,
                amb_time: 4_294_663.962,
                lap_number: 2
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 22.612,
                amb_time: 4_294_686.574,
                lap_number: 3
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 23.203,
                amb_time: 4_294_709.777,
                lap_number: 4
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 24.043,
                amb_time: 4_294_733.82,
                lap_number: 5
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 22.753,
                amb_time: 4_294_756.573,
                lap_number: 6
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 22.728,
                amb_time: 4_294_779.301,
                lap_number: 7
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 22.587,
                amb_time: 4_294_801.888,
                lap_number: 8
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 22.584,
                amb_time: 4_294_824.472,
                lap_number: 9
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 23.062,
                amb_time: 4_294_847.534,
                lap_number: 10
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 22.89,
                amb_time: 4_294_870.424,
                lap_number: 11
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 22.703,
                amb_time: 4_294_893.127,
                lap_number: 12
              }
            ],
            inserted_at: ~N[2023-11-19 12:48:18],
            updated_at: ~N[2023-11-19 12:48:18]
          }
        ],
        inserted_at: ~N[2023-11-19 12:48:17],
        updated_at: ~N[2023-11-19 12:49:26]
      },
      %KartVids.Races.Race{
        id: 22434,
        name: "12 Lap Junior - Group",
        external_race_id: "212612",
        started_at: ~U[2023-11-19 12:51:00Z],
        ended_at: ~U[2023-11-19 12:56:00Z],
        league?: false,
        league_type: :none,
        location_id: 1,
        season_id: 2,
        racers: [
          %KartVids.Races.Racer{
            id: 110_038,
            average_lap: 26.432999999999996,
            fastest_lap: 25.416,
            kart_num: 55,
            nickname: "Lewis Hamilton Jr.",
            photo: "https://aisdulles.clubspeedtiming.com/CustomerPictures/11286132.jpg",
            position: 4,
            external_racer_id: "11286132",
            race_by: :laps,
            win_by: :laptime,
            race_id: 22434,
            racer_profile_id: 31622,
            location_id: 1,
            laps: [
              %KartVids.Races.Racer.Lap{
                lap_time: 26.025,
                amb_time: 4_295_116.111,
                lap_number: 1
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 26.344,
                amb_time: 4_295_142.455,
                lap_number: 2
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 28.199,
                amb_time: 4_295_170.654,
                lap_number: 3
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 26.468,
                amb_time: 4_295_197.122,
                lap_number: 4
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 26.581,
                amb_time: 4_295_223.703,
                lap_number: 5
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 25.416,
                amb_time: 4_295_249.119,
                lap_number: 6
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 25.533,
                amb_time: 4_295_274.652,
                lap_number: 7
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 26.107,
                amb_time: 4_295_300.759,
                lap_number: 8
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 27.646,
                amb_time: 4_295_328.405,
                lap_number: 9
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 26.827,
                amb_time: 4_295_355.232,
                lap_number: 10
              }
            ],
            inserted_at: ~N[2023-11-19 12:56:01],
            updated_at: ~N[2023-11-19 12:56:01]
          },
          %KartVids.Races.Racer{
            id: 110_035,
            average_lap: 22.682285714285715,
            fastest_lap: 22.068,
            kart_num: 42,
            nickname: "Matteo",
            photo: "https://aisdulles.clubspeedtiming.com/CustomerPictures/8192924.jpg",
            position: 2,
            external_racer_id: "8192924",
            race_by: :laps,
            win_by: :laptime,
            race_id: 22434,
            racer_profile_id: 21380,
            location_id: 1,
            laps: [
              %KartVids.Races.Racer.Lap{
                lap_time: 22.069,
                amb_time: 4_295_098.358,
                lap_number: 1
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 22.068,
                amb_time: 4_295_120.426,
                lap_number: 2
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 22.315,
                amb_time: 4_295_142.741,
                lap_number: 3
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 22.368,
                amb_time: 4_295_165.109,
                lap_number: 4
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 22.141,
                amb_time: 4_295_187.25,
                lap_number: 5
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 22.339,
                amb_time: 4_295_209.589,
                lap_number: 6
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 22.721,
                amb_time: 4_295_232.31,
                lap_number: 7
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 22.418,
                amb_time: 4_295_254.728,
                lap_number: 8
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 22.853,
                amb_time: 4_295_277.581,
                lap_number: 9
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 24.433,
                amb_time: 4_295_302.014,
                lap_number: 10
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 23.868,
                amb_time: 4_295_325.882,
                lap_number: 11
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 23.821,
                amb_time: 4_295_349.703,
                lap_number: 12
              }
            ],
            inserted_at: ~N[2023-11-19 12:56:00],
            updated_at: ~N[2023-11-19 12:56:00]
          },
          %KartVids.Races.Racer{
            id: 110_037,
            average_lap: 21.78342857142857,
            fastest_lap: 21.432,
            kart_num: 52,
            nickname: "Lukas",
            photo: "https://aisdulles.clubspeedtiming.com/CustomerPictures/11212668.jpg",
            position: 1,
            external_racer_id: "11212668",
            race_by: :laps,
            win_by: :laptime,
            race_id: 22434,
            racer_profile_id: 132,
            location_id: 1,
            laps: [
              %KartVids.Races.Racer.Lap{
                lap_time: 21.505,
                amb_time: 4_295_110.763,
                lap_number: 1
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 21.432,
                amb_time: 4_295_132.195,
                lap_number: 2
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 21.788,
                amb_time: 4_295_153.983,
                lap_number: 3
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 23.036,
                amb_time: 4_295_177.019,
                lap_number: 4
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 21.511,
                amb_time: 4_295_198.53,
                lap_number: 5
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 22.348,
                amb_time: 4_295_220.878,
                lap_number: 6
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 21.611,
                amb_time: 4_295_242.489,
                lap_number: 7
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 21.701,
                amb_time: 4_295_264.19,
                lap_number: 8
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 21.748,
                amb_time: 4_295_285.938,
                lap_number: 9
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 21.616,
                amb_time: 4_295_307.554,
                lap_number: 10
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 21.624,
                amb_time: 4_295_329.178,
                lap_number: 11
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 22.038,
                amb_time: 4_295_351.216,
                lap_number: 12
              }
            ],
            inserted_at: ~N[2023-11-19 12:56:01],
            updated_at: ~N[2023-11-19 12:56:01]
          },
          %KartVids.Races.Racer{
            id: 110_036,
            average_lap: 24.108357142857148,
            fastest_lap: 23.067,
            kart_num: 45,
            nickname: "Tigey",
            photo: "https://aisdulles.clubspeedtiming.com/CustomerPictures/11235108.jpg",
            position: 3,
            external_racer_id: "11235108",
            race_by: :laps,
            win_by: :laptime,
            race_id: 22434,
            racer_profile_id: 30420,
            location_id: 1,
            laps: [
              %KartVids.Races.Racer.Lap{
                lap_time: 23.628,
                amb_time: 4_295_107.064,
                lap_number: 1
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 23.402,
                amb_time: 4_295_130.466,
                lap_number: 2
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 23.146,
                amb_time: 4_295_153.612,
                lap_number: 3
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 25.303,
                amb_time: 4_295_178.915,
                lap_number: 4
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 23.999,
                amb_time: 4_295_202.914,
                lap_number: 5
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 23.067,
                amb_time: 4_295_225.981,
                lap_number: 6
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 23.739,
                amb_time: 4_295_249.72,
                lap_number: 7
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 25.483,
                amb_time: 4_295_275.203,
                lap_number: 8
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 25.884,
                amb_time: 4_295_301.087,
                lap_number: 9
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 23.925,
                amb_time: 4_295_325.012,
                lap_number: 10
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 24.192,
                amb_time: 4_295_349.204,
                lap_number: 11
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 24.493,
                amb_time: 4_295_373.697,
                lap_number: 12
              }
            ],
            inserted_at: ~N[2023-11-19 12:56:00],
            updated_at: ~N[2023-11-19 12:56:00]
          }
        ],
        inserted_at: ~N[2023-11-19 12:56:00],
        updated_at: ~N[2023-11-19 16:46:02]
      },
      %KartVids.Races.Race{
        id: 22435,
        name: "12 Lap Junior - Group",
        external_race_id: "212613",
        started_at: ~U[2023-11-19 12:57:00Z],
        ended_at: ~U[2023-11-19 13:02:00Z],
        league?: false,
        league_type: :none,
        location_id: 1,
        season_id: 2,
        racers: [
          %KartVids.Races.Racer{
            id: 110_042,
            average_lap: 21.687071428571425,
            fastest_lap: 21.231,
            kart_num: 48,
            nickname: "Thomas_cruise Jr",
            photo: "https://aisdulles.clubspeedtiming.com/CustomerPictures/11240160.jpg",
            position: 1,
            external_racer_id: "11240160",
            race_by: :laps,
            win_by: :laptime,
            race_id: 22435,
            racer_profile_id: 1915,
            location_id: 1,
            laps: [
              %KartVids.Races.Racer.Lap{
                lap_time: 21.674,
                amb_time: 4_295_510.569,
                lap_number: 1
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 21.824,
                amb_time: 4_295_532.393,
                lap_number: 2
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 21.781,
                amb_time: 4_295_554.174,
                lap_number: 3
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 21.604,
                amb_time: 4_295_575.778,
                lap_number: 4
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 22.931,
                amb_time: 4_295_598.709,
                lap_number: 5
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 22.116,
                amb_time: 4_295_620.825,
                lap_number: 6
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 21.482,
                amb_time: 4_295_642.307,
                lap_number: 7
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 21.34,
                amb_time: 4_295_663.647,
                lap_number: 8
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 21.231,
                amb_time: 4_295_684.878,
                lap_number: 9
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 21.255,
                amb_time: 4_295_706.133,
                lap_number: 10
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 21.251,
                amb_time: 4_295_727.384,
                lap_number: 11
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 21.782,
                amb_time: 4_295_749.166,
                lap_number: 12
              }
            ],
            inserted_at: ~N[2023-11-19 13:02:47],
            updated_at: ~N[2023-11-19 13:02:47]
          },
          %KartVids.Races.Racer{
            id: 110_040,
            average_lap: 22.671857142857146,
            fastest_lap: 22.19,
            kart_num: 41,
            nickname: "Arjun",
            photo: "https://aisdulles.clubspeedtiming.com/CustomerPictures/11183110.jpg",
            position: 2,
            external_racer_id: "11183110",
            race_by: :laps,
            win_by: :laptime,
            race_id: 22435,
            racer_profile_id: 144,
            location_id: 1,
            laps: [
              %KartVids.Races.Racer.Lap{
                lap_time: 22.528,
                amb_time: 4_295_522.613,
                lap_number: 1
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 22.371,
                amb_time: 4_295_544.984,
                lap_number: 2
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 22.331,
                amb_time: 4_295_567.315,
                lap_number: 3
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 22.19,
                amb_time: 4_295_589.505,
                lap_number: 4
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 22.347,
                amb_time: 4_295_611.852,
                lap_number: 5
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 22.342,
                amb_time: 4_295_634.194,
                lap_number: 6
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 22.628,
                amb_time: 4_295_656.822,
                lap_number: 7
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 22.475,
                amb_time: 4_295_679.297,
                lap_number: 8
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 22.862,
                amb_time: 4_295_702.159,
                lap_number: 9
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 22.85,
                amb_time: 4_295_725.009,
                lap_number: 10
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 23.439,
                amb_time: 4_295_748.448,
                lap_number: 11
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 23.987,
                amb_time: 4_295_772.435,
                lap_number: 12
              }
            ],
            inserted_at: ~N[2023-11-19 13:02:47],
            updated_at: ~N[2023-11-19 13:02:47]
          },
          %KartVids.Races.Racer{
            id: 110_043,
            average_lap: 25.099307692307697,
            fastest_lap: 24.056,
            kart_num: 49,
            nickname: "Brayden Price",
            photo: "https://aisdulles.clubspeedtiming.com/CustomerPictures/11250686.jpg",
            position: 5,
            external_racer_id: "11250686",
            race_by: :laps,
            win_by: :laptime,
            race_id: 22435,
            racer_profile_id: 31621,
            location_id: 1,
            laps: [
              %KartVids.Races.Racer.Lap{
                lap_time: 25.688,
                amb_time: 4_295_522.118,
                lap_number: 1
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 26.584,
                amb_time: 4_295_548.702,
                lap_number: 2
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 25.253,
                amb_time: 4_295_573.955,
                lap_number: 3
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 25.937,
                amb_time: 4_295_599.892,
                lap_number: 4
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 24.551,
                amb_time: 4_295_624.443,
                lap_number: 5
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 24.083,
                amb_time: 4_295_648.526,
                lap_number: 6
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 24.101,
                amb_time: 4_295_672.627,
                lap_number: 7
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 24.396,
                amb_time: 4_295_697.023,
                lap_number: 8
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 25.992,
                amb_time: 4_295_723.015,
                lap_number: 9
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 24.056,
                amb_time: 4_295_747.071,
                lap_number: 10
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 24.274,
                amb_time: 4_295_771.345,
                lap_number: 11
              }
            ],
            inserted_at: ~N[2023-11-19 13:02:47],
            updated_at: ~N[2023-11-19 13:02:47]
          },
          %KartVids.Races.Racer{
            id: 110_041,
            average_lap: 24.733923076923077,
            fastest_lap: 22.963,
            kart_num: 43,
            nickname: "Rudy Smith",
            photo: "https://aisdulles.clubspeedtiming.com/CustomerPictures/11238419.jpg",
            position: 4,
            external_racer_id: "11238419",
            race_by: :laps,
            win_by: :laptime,
            race_id: 22435,
            racer_profile_id: 31618,
            location_id: 1,
            laps: [
              %KartVids.Races.Racer.Lap{
                lap_time: 24.651,
                amb_time: 4_295_531.201,
                lap_number: 1
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 25.48,
                amb_time: 4_295_556.681,
                lap_number: 2
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 24.894,
                amb_time: 4_295_581.575,
                lap_number: 3
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 24.499,
                amb_time: 4_295_606.074,
                lap_number: 4
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 24.254,
                amb_time: 4_295_630.328,
                lap_number: 5
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 24.007,
                amb_time: 4_295_654.335,
                lap_number: 6
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 23.835,
                amb_time: 4_295_678.17,
                lap_number: 7
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 23.846,
                amb_time: 4_295_702.016,
                lap_number: 8
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 23.835,
                amb_time: 4_295_725.851,
                lap_number: 9
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 22.963,
                amb_time: 4_295_748.814,
                lap_number: 10
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 29.975,
                amb_time: 4_295_778.789,
                lap_number: 11
              }
            ],
            inserted_at: ~N[2023-11-19 13:02:47],
            updated_at: ~N[2023-11-19 13:02:47]
          },
          %KartVids.Races.Racer{
            id: 110_039,
            average_lap: 24.13784615384615,
            fastest_lap: 22.869,
            kart_num: 40,
            nickname: "Owen",
            photo: "https://aisdulles.clubspeedtiming.com/CustomerPictures/11281138.jpg",
            position: 3,
            external_racer_id: "11281138",
            race_by: :laps,
            win_by: :laptime,
            race_id: 22435,
            racer_profile_id: 27506,
            location_id: 1,
            laps: [
              %KartVids.Races.Racer.Lap{
                lap_time: 25.692,
                amb_time: 4_295_523.164,
                lap_number: 1
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 26.218,
                amb_time: 4_295_549.382,
                lap_number: 2
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 24.926,
                amb_time: 4_295_574.308,
                lap_number: 3
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 23.134,
                amb_time: 4_295_597.442,
                lap_number: 4
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 23.035,
                amb_time: 4_295_620.477,
                lap_number: 5
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 23.389,
                amb_time: 4_295_643.866,
                lap_number: 6
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 22.869,
                amb_time: 4_295_666.735,
                lap_number: 7
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 22.905,
                amb_time: 4_295_689.64,
                lap_number: 8
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 23.05,
                amb_time: 4_295_712.69,
                lap_number: 9
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 23.442,
                amb_time: 4_295_736.132,
                lap_number: 10
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 23.748,
                amb_time: 4_295_759.88,
                lap_number: 11
              }
            ],
            inserted_at: ~N[2023-11-19 13:02:47],
            updated_at: ~N[2023-11-19 13:02:47]
          }
        ],
        inserted_at: ~N[2023-11-19 13:02:47],
        updated_at: ~N[2023-11-19 13:04:29]
      },
      %KartVids.Races.Race{
        id: 22437,
        name: "8 Lap",
        external_race_id: "212589",
        started_at: ~U[2023-11-19 13:35:00Z],
        ended_at: ~U[2023-11-19 13:39:00Z],
        league?: false,
        league_type: :none,
        location_id: 1,
        season_id: 2,
        racers: [
          %KartVids.Races.Racer{
            id: 110_045,
            average_lap: 28.8913,
            fastest_lap: 26.284,
            kart_num: 31,
            nickname: "Lewis Hamilton Jr.",
            photo: "https://aisdulles.clubspeedtiming.com/CustomerPictures/11286132.jpg",
            position: 4,
            external_racer_id: "11286132",
            race_by: :laps,
            win_by: :laptime,
            race_id: 22437,
            racer_profile_id: 31622,
            location_id: 1,
            laps: [
              %KartVids.Races.Racer.Lap{
                lap_time: 28.658,
                amb_time: 4_297_750.602,
                lap_number: 1
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 26.284,
                amb_time: 4_297_776.886,
                lap_number: 2
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 29.472,
                amb_time: 4_297_806.358,
                lap_number: 3
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 26.678,
                amb_time: 4_297_833.036,
                lap_number: 4
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 27.126,
                amb_time: 4_297_860.162,
                lap_number: 5
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 39.265,
                amb_time: 4_297_899.427,
                lap_number: 6
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 27.828,
                amb_time: 4_297_927.255,
                lap_number: 7
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 26.286,
                amb_time: 4_297_953.541,
                lap_number: 8
              }
            ],
            inserted_at: ~N[2023-11-19 13:39:03],
            updated_at: ~N[2023-11-19 13:39:03]
          },
          %KartVids.Races.Racer{
            id: 110_047,
            average_lap: 25.9848,
            fastest_lap: 22.989,
            kart_num: 49,
            nickname: "Jackson",
            photo: "https://aisdulles.clubspeedtiming.com/CustomerPictures/11241047.jpg",
            position: 1,
            external_racer_id: "11241047",
            race_by: :laps,
            win_by: :laptime,
            race_id: 22437,
            racer_profile_id: 760,
            location_id: 1,
            laps: [
              %KartVids.Races.Racer.Lap{
                lap_time: 23.266,
                amb_time: 4_297_752.145,
                lap_number: 1
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 25.464,
                amb_time: 4_297_777.609,
                lap_number: 2
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 25.494,
                amb_time: 4_297_803.103,
                lap_number: 3
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 22.989,
                amb_time: 4_297_826.092,
                lap_number: 4
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 24.025,
                amb_time: 4_297_850.117,
                lap_number: 5
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 24.309,
                amb_time: 4_297_874.426,
                lap_number: 6
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 43.198,
                amb_time: 4_297_917.624,
                lap_number: 7
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 24.571,
                amb_time: 4_297_942.195,
                lap_number: 8
              }
            ],
            inserted_at: ~N[2023-11-19 13:39:03],
            updated_at: ~N[2023-11-19 13:39:03]
          },
          %KartVids.Races.Racer{
            id: 110_048,
            average_lap: 27.006999999999998,
            fastest_lap: 24.177,
            kart_num: 50,
            nickname: "Brayden Price",
            photo: "https://aisdulles.clubspeedtiming.com/CustomerPictures/11250686.jpg",
            position: 3,
            external_racer_id: "11250686",
            race_by: :laps,
            win_by: :laptime,
            race_id: 22437,
            racer_profile_id: 31621,
            location_id: 1,
            laps: [
              %KartVids.Races.Racer.Lap{
                lap_time: 25.074,
                amb_time: 4_297_814.101,
                lap_number: 1
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 24.97,
                amb_time: 4_297_839.071,
                lap_number: 2
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 24.766,
                amb_time: 4_297_863.837,
                lap_number: 3
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 41.417,
                amb_time: 4_297_905.254,
                lap_number: 4
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 25.504,
                amb_time: 4_297_930.758,
                lap_number: 5
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 24.177,
                amb_time: 4_297_954.935,
                lap_number: 6
              }
            ],
            inserted_at: ~N[2023-11-19 13:39:03],
            updated_at: ~N[2023-11-19 13:39:03]
          },
          %KartVids.Races.Racer{
            id: 110_046,
            average_lap: 28.692700000000002,
            fastest_lap: 23.065,
            kart_num: 47,
            nickname: "V1SNKRboi",
            photo: "https://aisdulles.clubspeedtiming.com/CustomerPictures/11191397.jpg",
            position: 2,
            external_racer_id: "11191397",
            race_by: :laps,
            win_by: :laptime,
            race_id: 22437,
            racer_profile_id: 27434,
            location_id: 1,
            laps: [
              %KartVids.Races.Racer.Lap{
                lap_time: 27.249,
                amb_time: 4_297_751.142,
                lap_number: 1
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 26.742,
                amb_time: 4_297_777.884,
                lap_number: 2
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 26.188,
                amb_time: 4_297_804.072,
                lap_number: 3
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 23.906,
                amb_time: 4_297_827.978,
                lap_number: 4
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 23.407,
                amb_time: 4_297_851.385,
                lap_number: 5
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 57.82,
                amb_time: 4_297_909.205,
                lap_number: 6
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 24.052,
                amb_time: 4_297_933.257,
                lap_number: 7
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 23.065,
                amb_time: 4_297_956.322,
                lap_number: 8
              }
            ],
            inserted_at: ~N[2023-11-19 13:39:03],
            updated_at: ~N[2023-11-19 13:39:03]
          }
        ],
        inserted_at: ~N[2023-11-19 13:39:03],
        updated_at: ~N[2023-11-19 16:46:35]
      },
      %KartVids.Races.Race{
        id: 22438,
        name: "8 Lap",
        external_race_id: "212590",
        started_at: ~U[2023-11-19 13:41:00Z],
        ended_at: ~U[2023-11-19 13:44:00Z],
        league?: false,
        league_type: :none,
        location_id: 1,
        season_id: 2,
        racers: [
          %KartVids.Races.Racer{
            id: 110_052,
            average_lap: 23.056,
            fastest_lap: 22.536,
            kart_num: 55,
            nickname: "Liam OBrien",
            photo: "https://aisdulles.clubspeedtiming.com/CustomerPictures/11207451.jpg",
            position: 2,
            external_racer_id: "11207451",
            race_by: :laps,
            win_by: :laptime,
            race_id: 22438,
            racer_profile_id: 31619,
            location_id: 1,
            laps: [
              %KartVids.Races.Racer.Lap{
                lap_time: 23.35,
                amb_time: 4_298_141.609,
                lap_number: 1
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 23.006,
                amb_time: 4_298_164.615,
                lap_number: 2
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 23.339,
                amb_time: 4_298_187.954,
                lap_number: 3
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 22.933,
                amb_time: 4_298_210.887,
                lap_number: 4
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 22.719,
                amb_time: 4_298_233.606,
                lap_number: 5
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 22.761,
                amb_time: 4_298_256.367,
                lap_number: 6
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 22.536,
                amb_time: 4_298_278.903,
                lap_number: 7
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 23.216,
                amb_time: 4_298_302.119,
                lap_number: 8
              }
            ],
            inserted_at: ~N[2023-11-19 13:44:50],
            updated_at: ~N[2023-11-19 13:44:50]
          },
          %KartVids.Races.Racer{
            id: 110_049,
            average_lap: 21.762999999999998,
            fastest_lap: 21.664,
            kart_num: 32,
            nickname: "Emmitt",
            photo: "https://aisdulles.clubspeedtiming.com/CustomerPictures/1519776.jpg",
            position: 1,
            external_racer_id: "1519776",
            race_by: :laps,
            win_by: :laptime,
            race_id: 22438,
            racer_profile_id: 125,
            location_id: 1,
            laps: [
              %KartVids.Races.Racer.Lap{
                lap_time: 21.726,
                amb_time: 4_298_135.38,
                lap_number: 1
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 21.806,
                amb_time: 4_298_157.186,
                lap_number: 2
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 21.664,
                amb_time: 4_298_178.85,
                lap_number: 3
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 21.675,
                amb_time: 4_298_200.525,
                lap_number: 4
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 21.868,
                amb_time: 4_298_222.393,
                lap_number: 5
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 21.7,
                amb_time: 4_298_244.093,
                lap_number: 6
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 21.787,
                amb_time: 4_298_265.88,
                lap_number: 7
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 21.952,
                amb_time: 4_298_287.832,
                lap_number: 8
              }
            ],
            inserted_at: ~N[2023-11-19 13:44:50],
            updated_at: ~N[2023-11-19 13:44:50]
          },
          %KartVids.Races.Racer{
            id: 110_050,
            average_lap: 23.919777777777778,
            fastest_lap: 23.166,
            kart_num: 42,
            nickname: "Rudy Smith",
            photo: "https://aisdulles.clubspeedtiming.com/CustomerPictures/11238419.jpg",
            position: 4,
            external_racer_id: "11238419",
            race_by: :laps,
            win_by: :laptime,
            race_id: 22438,
            racer_profile_id: 31618,
            location_id: 1,
            laps: [
              %KartVids.Races.Racer.Lap{
                lap_time: 24.376,
                amb_time: 4_298_147.446,
                lap_number: 1
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 23.87,
                amb_time: 4_298_171.316,
                lap_number: 2
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 23.741,
                amb_time: 4_298_195.057,
                lap_number: 3
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 23.678,
                amb_time: 4_298_218.735,
                lap_number: 4
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 23.533,
                amb_time: 4_298_242.268,
                lap_number: 5
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 23.166,
                amb_time: 4_298_265.434,
                lap_number: 6
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 24.162,
                amb_time: 4_298_289.596,
                lap_number: 7
              }
            ],
            inserted_at: ~N[2023-11-19 13:44:50],
            updated_at: ~N[2023-11-19 13:44:50]
          },
          %KartVids.Races.Racer{
            id: 110_051,
            average_lap: 23.9895,
            fastest_lap: 23.139,
            kart_num: 46,
            nickname: "Tigey",
            photo: "https://aisdulles.clubspeedtiming.com/CustomerPictures/11235108.jpg",
            position: 3,
            external_racer_id: "11235108",
            race_by: :laps,
            win_by: :laptime,
            race_id: 22438,
            racer_profile_id: 30420,
            location_id: 1,
            laps: [
              %KartVids.Races.Racer.Lap{
                lap_time: 23.728,
                amb_time: 4_298_133.083,
                lap_number: 1
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 25.311,
                amb_time: 4_298_158.394,
                lap_number: 2
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 24.092,
                amb_time: 4_298_182.486,
                lap_number: 3
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 24.104,
                amb_time: 4_298_206.59,
                lap_number: 4
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 23.583,
                amb_time: 4_298_230.173,
                lap_number: 5
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 24.468,
                amb_time: 4_298_254.641,
                lap_number: 6
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 23.139,
                amb_time: 4_298_277.78,
                lap_number: 7
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 24.014,
                amb_time: 4_298_301.794,
                lap_number: 8
              }
            ],
            inserted_at: ~N[2023-11-19 13:44:50],
            updated_at: ~N[2023-11-19 13:44:50]
          }
        ],
        inserted_at: ~N[2023-11-19 13:44:50],
        updated_at: ~N[2023-11-19 16:46:39]
      },
      %KartVids.Races.Race{
        id: 22439,
        name: "8 Lap",
        external_race_id: "212591",
        started_at: ~U[2023-11-19 13:54:00Z],
        ended_at: ~U[2023-11-19 13:58:00Z],
        league?: false,
        league_type: :none,
        location_id: 1,
        season_id: 2,
        racers: [
          %KartVids.Races.Racer{
            id: 110_054,
            average_lap: 23.4797,
            fastest_lap: 23.174,
            kart_num: 41,
            nickname: "Han",
            photo: "https://aisdulles.clubspeedtiming.com/CustomerPictures/11233289.jpg",
            position: 5,
            external_racer_id: "11233289",
            race_by: :laps,
            win_by: :laptime,
            race_id: 22439,
            racer_profile_id: 19003,
            location_id: 1,
            laps: [
              %KartVids.Races.Racer.Lap{
                lap_time: 23.174,
                amb_time: 4_298_935.687,
                lap_number: 1
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 23.335,
                amb_time: 4_298_959.022,
                lap_number: 2
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 23.433,
                amb_time: 4_298_982.455,
                lap_number: 3
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 23.422,
                amb_time: 4_299_005.877,
                lap_number: 4
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 23.383,
                amb_time: 4_299_029.26,
                lap_number: 5
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 23.753,
                amb_time: 4_299_053.013,
                lap_number: 6
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 23.944,
                amb_time: 4_299_076.957,
                lap_number: 7
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 24.005,
                amb_time: 4_299_100.962,
                lap_number: 8
              }
            ],
            inserted_at: ~N[2023-11-19 13:58:13],
            updated_at: ~N[2023-11-19 13:58:13]
          },
          %KartVids.Races.Racer{
            id: 110_057,
            average_lap: 22.9276,
            fastest_lap: 22.441,
            kart_num: 50,
            nickname: "Bryson",
            photo: "https://aisdulles.clubspeedtiming.com/CustomerPictures/11274283.jpg",
            position: 4,
            external_racer_id: "11274283",
            race_by: :laps,
            win_by: :laptime,
            race_id: 22439,
            racer_profile_id: 21560,
            location_id: 1,
            laps: [
              %KartVids.Races.Racer.Lap{
                lap_time: 22.955,
                amb_time: 4_298_943.934,
                lap_number: 1
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 23.068,
                amb_time: 4_298_967.002,
                lap_number: 2
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 23.239,
                amb_time: 4_298_990.241,
                lap_number: 3
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 22.552,
                amb_time: 4_299_012.793,
                lap_number: 4
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 22.441,
                amb_time: 4_299_035.234,
                lap_number: 5
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 22.828,
                amb_time: 4_299_058.062,
                lap_number: 6
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 22.918,
                amb_time: 4_299_080.98,
                lap_number: 7
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 23.365,
                amb_time: 4_299_104.345,
                lap_number: 8
              }
            ],
            inserted_at: ~N[2023-11-19 13:58:13],
            updated_at: ~N[2023-11-19 13:58:13]
          },
          %KartVids.Races.Racer{
            id: 110_056,
            average_lap: 23.143700000000003,
            fastest_lap: 22.407,
            kart_num: 49,
            nickname: "Speedy Turtle",
            photo: "https://aisdulles.clubspeedtiming.com/CustomerPictures/8182382.jpg",
            position: 3,
            external_racer_id: "8182382",
            race_by: :laps,
            win_by: :laptime,
            race_id: 22439,
            racer_profile_id: 22375,
            location_id: 1,
            laps: [
              %KartVids.Races.Racer.Lap{
                lap_time: 22.407,
                amb_time: 4_298_938.282,
                lap_number: 1
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 22.892,
                amb_time: 4_298_961.174,
                lap_number: 2
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 22.845,
                amb_time: 4_298_984.019,
                lap_number: 3
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 24.16,
                amb_time: 4_299_008.179,
                lap_number: 4
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 23.426,
                amb_time: 4_299_031.605,
                lap_number: 5
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 23.276,
                amb_time: 4_299_054.881,
                lap_number: 6
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 23.513,
                amb_time: 4_299_078.394,
                lap_number: 7
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 24.104,
                amb_time: 4_299_102.498,
                lap_number: 8
              }
            ],
            inserted_at: ~N[2023-11-19 13:58:13],
            updated_at: ~N[2023-11-19 13:58:13]
          },
          %KartVids.Races.Racer{
            id: 110_055,
            average_lap: 22.375499999999995,
            fastest_lap: 21.879,
            kart_num: 48,
            nickname: "Owen",
            photo: "https://aisdulles.clubspeedtiming.com/CustomerPictures/11281138.jpg",
            position: 1,
            external_racer_id: "11281138",
            race_by: :laps,
            win_by: :laptime,
            race_id: 22439,
            racer_profile_id: 27506,
            location_id: 1,
            laps: [
              %KartVids.Races.Racer.Lap{
                lap_time: 22.572,
                amb_time: 4_298_925.666,
                lap_number: 1
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 22.888,
                amb_time: 4_298_948.554,
                lap_number: 2
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 22.541,
                amb_time: 4_298_971.095,
                lap_number: 3
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 22.498,
                amb_time: 4_298_993.593,
                lap_number: 4
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 22.19,
                amb_time: 4_299_015.783,
                lap_number: 5
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 21.916,
                amb_time: 4_299_037.699,
                lap_number: 6
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 21.879,
                amb_time: 4_299_059.578,
                lap_number: 7
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 22.127,
                amb_time: 4_299_081.705,
                lap_number: 8
              }
            ],
            inserted_at: ~N[2023-11-19 13:58:13],
            updated_at: ~N[2023-11-19 13:58:13]
          },
          %KartVids.Races.Racer{
            id: 110_053,
            average_lap: 22.374299999999998,
            fastest_lap: 22.167,
            kart_num: 40,
            nickname: "Paul",
            photo: "https://aisdulles.clubspeedtiming.com/CustomerPictures/11233287.jpg",
            position: 2,
            external_racer_id: "11233287",
            race_by: :laps,
            win_by: :laptime,
            race_id: 22439,
            racer_profile_id: 18997,
            location_id: 1,
            laps: [
              %KartVids.Races.Racer.Lap{
                lap_time: 22.23,
                amb_time: 4_298_929.342,
                lap_number: 1
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 22.22,
                amb_time: 4_298_951.562,
                lap_number: 2
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 22.886,
                amb_time: 4_298_974.448,
                lap_number: 3
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 22.64,
                amb_time: 4_298_997.088,
                lap_number: 4
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 22.296,
                amb_time: 4_299_019.384,
                lap_number: 5
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 22.167,
                amb_time: 4_299_041.551,
                lap_number: 6
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 22.448,
                amb_time: 4_299_063.999,
                lap_number: 7
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 22.396,
                amb_time: 4_299_086.395,
                lap_number: 8
              }
            ],
            inserted_at: ~N[2023-11-19 13:58:13],
            updated_at: ~N[2023-11-19 13:58:13]
          }
        ],
        inserted_at: ~N[2023-11-19 13:58:13],
        updated_at: ~N[2023-11-19 16:46:44]
      },
      %KartVids.Races.Race{
        id: 22440,
        name: "8 Lap",
        external_race_id: "212592",
        started_at: ~U[2023-11-19 14:00:00Z],
        ended_at: ~U[2023-11-19 14:05:00Z],
        league?: false,
        league_type: :none,
        location_id: 1,
        season_id: 2,
        racers: [
          %KartVids.Races.Racer{
            id: 110_061,
            average_lap: 32.12319999999999,
            fastest_lap: 22.674,
            kart_num: 45,
            nickname: "Austin",
            photo: "https://aisdulles.clubspeedtiming.com/CustomerPictures/11199007.jpg",
            position: 5,
            external_racer_id: "11199007",
            race_by: :laps,
            win_by: :laptime,
            race_id: 22440,
            racer_profile_id: 12532,
            location_id: 1,
            laps: [
              %KartVids.Races.Racer.Lap{
                lap_time: 23.09,
                amb_time: 4_299_253.941,
                lap_number: 1
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 23.504,
                amb_time: 4_299_277.445,
                lap_number: 2
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 112.142,
                amb_time: 4_299_389.587,
                lap_number: 3
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 22.674,
                amb_time: 4_299_412.261,
                lap_number: 4
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 22.837,
                amb_time: 4_299_435.098,
                lap_number: 5
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 24.119,
                amb_time: 4_299_459.217,
                lap_number: 6
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 22.77,
                amb_time: 4_299_481.987,
                lap_number: 7
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 23.916,
                amb_time: 4_299_505.903,
                lap_number: 8
              }
            ],
            inserted_at: ~N[2023-11-19 14:05:05],
            updated_at: ~N[2023-11-19 14:05:05]
          },
          %KartVids.Races.Racer{
            id: 110_058,
            average_lap: 30.9214,
            fastest_lap: 21.512,
            kart_num: 32,
            nickname: "Danny Jauregui",
            photo: "https://aisdulles.clubspeedtiming.com/CustomerPictures/11258317.jpg",
            position: 2,
            external_racer_id: "11258317",
            race_by: :laps,
            win_by: :laptime,
            race_id: 22440,
            racer_profile_id: 10249,
            location_id: 1,
            laps: [
              %KartVids.Races.Racer.Lap{
                lap_time: 21.638,
                amb_time: 4_299_257.382,
                lap_number: 1
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 21.622,
                amb_time: 4_299_279.004,
                lap_number: 2
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 114.027,
                amb_time: 4_299_393.031,
                lap_number: 3
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 21.512,
                amb_time: 4_299_414.543,
                lap_number: 4
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 21.599,
                amb_time: 4_299_436.142,
                lap_number: 5
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 22.378,
                amb_time: 4_299_458.52,
                lap_number: 6
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 21.638,
                amb_time: 4_299_480.158,
                lap_number: 7
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 21.524,
                amb_time: 4_299_501.682,
                lap_number: 8
              }
            ],
            inserted_at: ~N[2023-11-19 14:05:05],
            updated_at: ~N[2023-11-19 14:05:05]
          },
          %KartVids.Races.Racer{
            id: 110_059,
            average_lap: 30.8418,
            fastest_lap: 21.423,
            kart_num: 42,
            nickname: "Bentlee",
            photo: "https://aisdulles.clubspeedtiming.com/CustomerPictures/11187444.jpg",
            position: 1,
            external_racer_id: "11187444",
            race_by: :laps,
            win_by: :laptime,
            race_id: 22440,
            racer_profile_id: 8211,
            location_id: 1,
            laps: [
              %KartVids.Races.Racer.Lap{
                lap_time: 21.423,
                amb_time: 4_299_261.254,
                lap_number: 1
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 21.527,
                amb_time: 4_299_282.781,
                lap_number: 2
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 113.717,
                amb_time: 4_299_396.498,
                lap_number: 3
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 21.639,
                amb_time: 4_299_418.137,
                lap_number: 4
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 21.869,
                amb_time: 4_299_440.006,
                lap_number: 5
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 21.723,
                amb_time: 4_299_461.729,
                lap_number: 6
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 21.708,
                amb_time: 4_299_483.437,
                lap_number: 7
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 21.966,
                amb_time: 4_299_505.403,
                lap_number: 8
              }
            ],
            inserted_at: ~N[2023-11-19 14:05:05],
            updated_at: ~N[2023-11-19 14:05:05]
          },
          %KartVids.Races.Racer{
            id: 110_060,
            average_lap: 33.71560000000001,
            fastest_lap: 21.707,
            kart_num: 43,
            nickname: "Sebastian Zieglar",
            photo: "https://aisdulles.clubspeedtiming.com/CustomerPictures/11213892.jpg",
            position: 3,
            external_racer_id: "11213892",
            race_by: :laps,
            win_by: :laptime,
            race_id: 22440,
            racer_profile_id: 199,
            location_id: 1,
            laps: [
              %KartVids.Races.Racer.Lap{
                lap_time: 137.256,
                amb_time: 4_299_407.612,
                lap_number: 3
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 21.913,
                amb_time: 4_299_429.525,
                lap_number: 4
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 22.156,
                amb_time: 4_299_451.681,
                lap_number: 5
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 22.295,
                amb_time: 4_299_473.976,
                lap_number: 6
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 22.374,
                amb_time: 4_299_496.35,
                lap_number: 7
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 21.707,
                amb_time: 4_299_518.057,
                lap_number: 8
              }
            ],
            inserted_at: ~N[2023-11-19 14:05:05],
            updated_at: ~N[2023-11-19 14:05:05]
          },
          %KartVids.Races.Racer{
            id: 110_062,
            average_lap: 31.572400000000005,
            fastest_lap: 22.046,
            kart_num: 47,
            nickname: "Matteo",
            photo: "https://aisdulles.clubspeedtiming.com/CustomerPictures/8192924.jpg",
            position: 4,
            external_racer_id: "8192924",
            race_by: :laps,
            win_by: :laptime,
            race_id: 22440,
            racer_profile_id: 21380,
            location_id: 1,
            laps: [
              %KartVids.Races.Racer.Lap{
                lap_time: 22.262,
                amb_time: 4_299_266.635,
                lap_number: 1
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 22.937,
                amb_time: 4_299_289.572,
                lap_number: 2
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 114.914,
                amb_time: 4_299_404.486,
                lap_number: 3
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 22.046,
                amb_time: 4_299_426.532,
                lap_number: 4
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 22.114,
                amb_time: 4_299_448.646,
                lap_number: 5
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 22.511,
                amb_time: 4_299_471.157,
                lap_number: 6
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 22.333,
                amb_time: 4_299_493.49,
                lap_number: 7
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 22.083,
                amb_time: 4_299_515.573,
                lap_number: 8
              }
            ],
            inserted_at: ~N[2023-11-19 14:05:05],
            updated_at: ~N[2023-11-19 14:05:05]
          }
        ],
        inserted_at: ~N[2023-11-19 14:05:05],
        updated_at: ~N[2023-11-19 16:46:49]
      },
      %KartVids.Races.Race{
        id: 22441,
        name: "8 Lap",
        external_race_id: "212593",
        started_at: ~U[2023-11-19 14:09:00Z],
        ended_at: ~U[2023-11-19 14:12:00Z],
        league?: false,
        league_type: :none,
        location_id: 1,
        season_id: 2,
        racers: [
          %KartVids.Races.Racer{
            id: 110_066,
            average_lap: 21.610100000000003,
            fastest_lap: 21.029,
            kart_num: 49,
            nickname: "Milo AE86",
            photo: "https://aisdulles.clubspeedtiming.com/CustomerPictures/8176814.jpg",
            position: 2,
            external_racer_id: "8176814",
            race_by: :laps,
            win_by: :laptime,
            race_id: 22441,
            racer_profile_id: 33829,
            location_id: 1,
            laps: [
              %KartVids.Races.Racer.Lap{
                lap_time: 21.029,
                amb_time: 4_299_825.694,
                lap_number: 1
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 21.101,
                amb_time: 4_299_846.795,
                lap_number: 2
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 21.507,
                amb_time: 4_299_868.302,
                lap_number: 3
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 21.589,
                amb_time: 4_299_889.891,
                lap_number: 4
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 21.907,
                amb_time: 4_299_911.798,
                lap_number: 5
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 21.845,
                amb_time: 4_299_933.643,
                lap_number: 6
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 22.305,
                amb_time: 4_299_955.948,
                lap_number: 7
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 22.76,
                amb_time: 4_299_978.708,
                lap_number: 8
              }
            ],
            inserted_at: ~N[2023-11-19 14:12:49],
            updated_at: ~N[2023-11-19 14:12:49]
          },
          %KartVids.Races.Racer{
            id: 110_065,
            average_lap: 21.189999999999998,
            fastest_lap: 20.845,
            kart_num: 48,
            nickname: "Jacob",
            photo: "https://aisdulles.clubspeedtiming.com/CustomerPictures/11234123.jpg",
            position: 1,
            external_racer_id: "11234123",
            race_by: :laps,
            win_by: :laptime,
            race_id: 22441,
            racer_profile_id: 15295,
            location_id: 1,
            laps: [
              %KartVids.Races.Racer.Lap{
                lap_time: 21.414,
                amb_time: 4_299_821.792,
                lap_number: 1
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 21.228,
                amb_time: 4_299_843.02,
                lap_number: 2
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 21.306,
                amb_time: 4_299_864.326,
                lap_number: 3
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 21.125,
                amb_time: 4_299_885.451,
                lap_number: 4
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 21.078,
                amb_time: 4_299_906.529,
                lap_number: 5
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 21.054,
                amb_time: 4_299_927.583,
                lap_number: 6
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 21.022,
                amb_time: 4_299_948.605,
                lap_number: 7
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 20.845,
                amb_time: 4_299_969.45,
                lap_number: 8
              }
            ],
            inserted_at: ~N[2023-11-19 14:12:49],
            updated_at: ~N[2023-11-19 14:12:49]
          },
          %KartVids.Races.Racer{
            id: 110_064,
            average_lap: 21.2689,
            fastest_lap: 21.067,
            kart_num: 40,
            nickname: "Thomas_cruise Jr",
            photo: "https://aisdulles.clubspeedtiming.com/CustomerPictures/11240160.jpg",
            position: 3,
            external_racer_id: "11240160",
            race_by: :laps,
            win_by: :laptime,
            race_id: 22441,
            racer_profile_id: 1915,
            location_id: 1,
            laps: [
              %KartVids.Races.Racer.Lap{
                lap_time: 21.067,
                amb_time: 4_299_816.703,
                lap_number: 1
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 21.316,
                amb_time: 4_299_838.019,
                lap_number: 2
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 21.242,
                amb_time: 4_299_859.261,
                lap_number: 3
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 21.307,
                amb_time: 4_299_880.568,
                lap_number: 4
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 21.253,
                amb_time: 4_299_901.821,
                lap_number: 5
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 21.195,
                amb_time: 4_299_923.016,
                lap_number: 6
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 21.468,
                amb_time: 4_299_944.484,
                lap_number: 7
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 21.707,
                amb_time: 4_299_966.191,
                lap_number: 8
              }
            ],
            inserted_at: ~N[2023-11-19 14:12:49],
            updated_at: ~N[2023-11-19 14:12:49]
          },
          %KartVids.Races.Racer{
            id: 110_063,
            average_lap: 21.6883,
            fastest_lap: 21.469,
            kart_num: 31,
            nickname: "Arjun",
            photo: "https://aisdulles.clubspeedtiming.com/CustomerPictures/11183110.jpg",
            position: 5,
            external_racer_id: "11183110",
            race_by: :laps,
            win_by: :laptime,
            race_id: 22441,
            racer_profile_id: 144,
            location_id: 1,
            laps: [
              %KartVids.Races.Racer.Lap{
                lap_time: 21.743,
                amb_time: 4_299_813.91,
                lap_number: 1
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 21.785,
                amb_time: 4_299_835.695,
                lap_number: 2
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 21.469,
                amb_time: 4_299_857.164,
                lap_number: 3
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 21.744,
                amb_time: 4_299_878.908,
                lap_number: 4
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 21.525,
                amb_time: 4_299_900.433,
                lap_number: 5
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 21.632,
                amb_time: 4_299_922.065,
                lap_number: 6
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 21.709,
                amb_time: 4_299_943.774,
                lap_number: 7
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 21.79,
                amb_time: 4_299_965.564,
                lap_number: 8
              }
            ],
            inserted_at: ~N[2023-11-19 14:12:49],
            updated_at: ~N[2023-11-19 14:12:49]
          },
          %KartVids.Races.Racer{
            id: 110_067,
            average_lap: 21.6144,
            fastest_lap: 21.33,
            kart_num: 50,
            nickname: "Lukas",
            photo: "https://aisdulles.clubspeedtiming.com/CustomerPictures/11212668.jpg",
            position: 4,
            external_racer_id: "11212668",
            race_by: :laps,
            win_by: :laptime,
            race_id: 22441,
            racer_profile_id: 132,
            location_id: 1,
            laps: [
              %KartVids.Races.Racer.Lap{
                lap_time: 21.711,
                amb_time: 4_299_829.548,
                lap_number: 1
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 21.618,
                amb_time: 4_299_851.166,
                lap_number: 2
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 21.657,
                amb_time: 4_299_872.823,
                lap_number: 3
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 21.33,
                amb_time: 4_299_894.153,
                lap_number: 4
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 21.623,
                amb_time: 4_299_915.776,
                lap_number: 5
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 21.679,
                amb_time: 4_299_937.455,
                lap_number: 6
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 21.402,
                amb_time: 4_299_958.857,
                lap_number: 7
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 21.702,
                amb_time: 4_299_980.559,
                lap_number: 8
              }
            ],
            inserted_at: ~N[2023-11-19 14:12:49],
            updated_at: ~N[2023-11-19 14:12:49]
          }
        ],
        inserted_at: ~N[2023-11-19 14:12:49],
        updated_at: ~N[2023-11-19 16:46:53]
      },
      %KartVids.Races.Race{
        id: 22443,
        name: "8 Lap",
        external_race_id: "212594",
        started_at: ~U[2023-11-19 14:28:00Z],
        ended_at: ~U[2023-11-19 14:32:00Z],
        league?: false,
        league_type: :none,
        location_id: 1,
        season_id: 2,
        racers: [
          %KartVids.Races.Racer{
            id: 110_071,
            average_lap: 26.709111111111113,
            fastest_lap: 26.348,
            kart_num: 32,
            nickname: "Lewis Hamilton Jr.",
            photo: "https://aisdulles.clubspeedtiming.com/CustomerPictures/11286132.jpg",
            position: 3,
            external_racer_id: "11286132",
            race_by: :laps,
            win_by: :laptime,
            race_id: 22443,
            racer_profile_id: 31622,
            location_id: 1,
            laps: [
              %KartVids.Races.Racer.Lap{
                lap_time: 26.348,
                amb_time: 4_300_987.723,
                lap_number: 1
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 26.971,
                amb_time: 4_301_014.694,
                lap_number: 2
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 26.439,
                amb_time: 4_301_041.133,
                lap_number: 3
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 27.152,
                amb_time: 4_301_068.285,
                lap_number: 4
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 27.245,
                amb_time: 4_301_095.53,
                lap_number: 5
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 26.611,
                amb_time: 4_301_122.141,
                lap_number: 6
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 26.92,
                amb_time: 4_301_149.061,
                lap_number: 7
              }
            ],
            inserted_at: ~N[2023-11-19 14:32:48],
            updated_at: ~N[2023-11-19 14:32:48]
          },
          %KartVids.Races.Racer{
            id: 110_072,
            average_lap: 24.067899999999998,
            fastest_lap: 22.944,
            kart_num: 43,
            nickname: "Jackson",
            photo: "https://aisdulles.clubspeedtiming.com/CustomerPictures/11241047.jpg",
            position: 2,
            external_racer_id: "11241047",
            race_by: :laps,
            win_by: :laptime,
            race_id: 22443,
            racer_profile_id: 760,
            location_id: 1,
            laps: [
              %KartVids.Races.Racer.Lap{
                lap_time: 23.735,
                amb_time: 4_300_988.281,
                lap_number: 1
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 25.577,
                amb_time: 4_301_013.858,
                lap_number: 2
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 24.374,
                amb_time: 4_301_038.232,
                lap_number: 3
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 24.251,
                amb_time: 4_301_062.483,
                lap_number: 4
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 22.944,
                amb_time: 4_301_085.427,
                lap_number: 5
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 24.104,
                amb_time: 4_301_109.531,
                lap_number: 6
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 23.529,
                amb_time: 4_301_133.06,
                lap_number: 7
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 24.695,
                amb_time: 4_301_157.755,
                lap_number: 8
              }
            ],
            inserted_at: ~N[2023-11-19 14:32:48],
            updated_at: ~N[2023-11-19 14:32:48]
          },
          %KartVids.Races.Racer{
            id: 110_073,
            average_lap: 23.431199999999997,
            fastest_lap: 22.759,
            kart_num: 52,
            nickname: "V1SNKRboi",
            photo: "https://aisdulles.clubspeedtiming.com/CustomerPictures/11191397.jpg",
            position: 1,
            external_racer_id: "11191397",
            race_by: :laps,
            win_by: :laptime,
            race_id: 22443,
            racer_profile_id: 27434,
            location_id: 1,
            laps: [
              %KartVids.Races.Racer.Lap{
                lap_time: 23.365,
                amb_time: 4_300_976.598,
                lap_number: 1
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 22.983,
                amb_time: 4_300_999.581,
                lap_number: 2
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 23.93,
                amb_time: 4_301_023.511,
                lap_number: 3
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 23.849,
                amb_time: 4_301_047.36,
                lap_number: 4
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 22.759,
                amb_time: 4_301_070.119,
                lap_number: 5
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 24.368,
                amb_time: 4_301_094.487,
                lap_number: 6
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 23.148,
                amb_time: 4_301_117.635,
                lap_number: 7
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 23.18,
                amb_time: 4_301_140.815,
                lap_number: 8
              }
            ],
            inserted_at: ~N[2023-11-19 14:32:48],
            updated_at: ~N[2023-11-19 14:32:48]
          }
        ],
        inserted_at: ~N[2023-11-19 14:32:48],
        updated_at: ~N[2023-11-19 16:46:57]
      },
      %KartVids.Races.Race{
        id: 22444,
        name: "8 Lap",
        external_race_id: "212595",
        started_at: ~U[2023-11-19 14:33:00Z],
        ended_at: ~U[2023-11-19 14:36:00Z],
        league?: false,
        league_type: :none,
        location_id: 1,
        season_id: 2,
        racers: [
          %KartVids.Races.Racer{
            id: 110_074,
            average_lap: 23.676899999999996,
            fastest_lap: 22.72,
            kart_num: 31,
            nickname: "Rudy Smith",
            photo: "https://aisdulles.clubspeedtiming.com/CustomerPictures/11238419.jpg",
            position: 4,
            external_racer_id: "11238419",
            race_by: :laps,
            win_by: :laptime,
            race_id: 22444,
            racer_profile_id: 31618,
            location_id: 1,
            laps: [
              %KartVids.Races.Racer.Lap{
                lap_time: 24.284,
                amb_time: 4_301_255.458,
                lap_number: 1
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 25.481,
                amb_time: 4_301_280.939,
                lap_number: 2
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 23.278,
                amb_time: 4_301_304.217,
                lap_number: 3
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 22.823,
                amb_time: 4_301_327.04,
                lap_number: 4
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 22.893,
                amb_time: 4_301_349.933,
                lap_number: 5
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 23.499,
                amb_time: 4_301_373.432,
                lap_number: 6
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 23.223,
                amb_time: 4_301_396.655,
                lap_number: 7
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 22.72,
                amb_time: 4_301_419.375,
                lap_number: 8
              }
            ],
            inserted_at: ~N[2023-11-19 14:36:47],
            updated_at: ~N[2023-11-19 14:36:47]
          },
          %KartVids.Races.Racer{
            id: 110_075,
            average_lap: 22.828300000000002,
            fastest_lap: 22.134,
            kart_num: 40,
            nickname: "Liam OBrien",
            photo: "https://aisdulles.clubspeedtiming.com/CustomerPictures/11207451.jpg",
            position: 2,
            external_racer_id: "11207451",
            race_by: :laps,
            win_by: :laptime,
            race_id: 22444,
            racer_profile_id: 31619,
            location_id: 1,
            laps: [
              %KartVids.Races.Racer.Lap{
                lap_time: 23.292,
                amb_time: 4_301_247.821,
                lap_number: 1
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 22.642,
                amb_time: 4_301_270.463,
                lap_number: 2
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 22.471,
                amb_time: 4_301_292.934,
                lap_number: 3
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 22.581,
                amb_time: 4_301_315.515,
                lap_number: 4
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 22.954,
                amb_time: 4_301_338.469,
                lap_number: 5
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 22.997,
                amb_time: 4_301_361.466,
                lap_number: 6
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 22.628,
                amb_time: 4_301_384.094,
                lap_number: 7
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 22.134,
                amb_time: 4_301_406.228,
                lap_number: 8
              }
            ],
            inserted_at: ~N[2023-11-19 14:36:47],
            updated_at: ~N[2023-11-19 14:36:47]
          },
          %KartVids.Races.Racer{
            id: 110_076,
            average_lap: 21.892000000000003,
            fastest_lap: 21.362,
            kart_num: 47,
            nickname: "Emmitt",
            photo: "https://aisdulles.clubspeedtiming.com/CustomerPictures/1519776.jpg",
            position: 1,
            external_racer_id: "1519776",
            race_by: :laps,
            win_by: :laptime,
            race_id: 22444,
            racer_profile_id: 125,
            location_id: 1,
            laps: [
              %KartVids.Races.Racer.Lap{
                lap_time: 21.895,
                amb_time: 4_301_256.441,
                lap_number: 1
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 22.954,
                amb_time: 4_301_279.395,
                lap_number: 2
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 21.719,
                amb_time: 4_301_301.114,
                lap_number: 3
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 21.57,
                amb_time: 4_301_322.684,
                lap_number: 4
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 21.547,
                amb_time: 4_301_344.231,
                lap_number: 5
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 21.362,
                amb_time: 4_301_365.593,
                lap_number: 6
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 21.598,
                amb_time: 4_301_387.191,
                lap_number: 7
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 22.485,
                amb_time: 4_301_409.676,
                lap_number: 8
              }
            ],
            inserted_at: ~N[2023-11-19 14:36:47],
            updated_at: ~N[2023-11-19 14:36:47]
          },
          %KartVids.Races.Racer{
            id: 110_077,
            average_lap: 23.6771,
            fastest_lap: 22.68,
            kart_num: 48,
            nickname: "Tigey",
            photo: "https://aisdulles.clubspeedtiming.com/CustomerPictures/11235108.jpg",
            position: 3,
            external_racer_id: "11235108",
            race_by: :laps,
            win_by: :laptime,
            race_id: 22444,
            racer_profile_id: 30420,
            location_id: 1,
            laps: [
              %KartVids.Races.Racer.Lap{
                lap_time: 23.97,
                amb_time: 4_301_244.611,
                lap_number: 1
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 23.364,
                amb_time: 4_301_267.975,
                lap_number: 2
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 23.807,
                amb_time: 4_301_291.782,
                lap_number: 3
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 23.284,
                amb_time: 4_301_315.066,
                lap_number: 4
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 24.736,
                amb_time: 4_301_339.802,
                lap_number: 5
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 23.248,
                amb_time: 4_301_363.05,
                lap_number: 6
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 23.742,
                amb_time: 4_301_386.792,
                lap_number: 7
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 22.68,
                amb_time: 4_301_409.472,
                lap_number: 8
              }
            ],
            inserted_at: ~N[2023-11-19 14:36:47],
            updated_at: ~N[2023-11-19 14:36:47]
          }
        ],
        inserted_at: ~N[2023-11-19 14:36:47],
        updated_at: ~N[2023-11-19 16:47:01]
      },
      %KartVids.Races.Race{
        id: 22445,
        name: "8 Lap",
        external_race_id: "212596",
        started_at: ~U[2023-11-19 14:43:00Z],
        ended_at: ~U[2023-11-19 14:46:00Z],
        league?: false,
        league_type: :none,
        location_id: 1,
        season_id: 2,
        racers: [
          %KartVids.Races.Racer{
            id: 110_078,
            average_lap: 22.6035,
            fastest_lap: 22.266,
            kart_num: 32,
            nickname: "Paul",
            photo: "https://aisdulles.clubspeedtiming.com/CustomerPictures/11233287.jpg",
            position: 2,
            external_racer_id: "11233287",
            race_by: :laps,
            win_by: :laptime,
            race_id: 22445,
            racer_profile_id: 18997,
            location_id: 1,
            laps: [
              %KartVids.Races.Racer.Lap{
                lap_time: 22.73,
                amb_time: 4_301_836.6,
                lap_number: 1
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 22.456,
                amb_time: 4_301_859.056,
                lap_number: 2
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 22.266,
                amb_time: 4_301_881.322,
                lap_number: 3
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 22.725,
                amb_time: 4_301_904.047,
                lap_number: 4
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 22.76,
                amb_time: 4_301_926.807,
                lap_number: 5
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 22.475,
                amb_time: 4_301_949.282,
                lap_number: 6
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 22.741,
                amb_time: 4_301_972.023,
                lap_number: 7
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 22.422,
                amb_time: 4_301_994.445,
                lap_number: 8
              }
            ],
            inserted_at: ~N[2023-11-19 14:46:33],
            updated_at: ~N[2023-11-19 14:46:33]
          },
          %KartVids.Races.Racer{
            id: 110_082,
            average_lap: 22.642699999999998,
            fastest_lap: 22.354,
            kart_num: 55,
            nickname: "Bryson",
            photo: "https://aisdulles.clubspeedtiming.com/CustomerPictures/11274283.jpg",
            position: 3,
            external_racer_id: "11274283",
            race_by: :laps,
            win_by: :laptime,
            race_id: 22445,
            racer_profile_id: 21560,
            location_id: 1,
            laps: [
              %KartVids.Races.Racer.Lap{
                lap_time: 22.629,
                amb_time: 4_301_826.062,
                lap_number: 1
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 22.673,
                amb_time: 4_301_848.735,
                lap_number: 2
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 22.718,
                amb_time: 4_301_871.453,
                lap_number: 3
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 22.519,
                amb_time: 4_301_893.972,
                lap_number: 4
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 23.051,
                amb_time: 4_301_917.023,
                lap_number: 5
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 22.354,
                amb_time: 4_301_939.377,
                lap_number: 6
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 22.718,
                amb_time: 4_301_962.095,
                lap_number: 7
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 22.507,
                amb_time: 4_301_984.602,
                lap_number: 8
              }
            ],
            inserted_at: ~N[2023-11-19 14:46:33],
            updated_at: ~N[2023-11-19 14:46:33]
          },
          %KartVids.Races.Racer{
            id: 110_080,
            average_lap: 23.2885,
            fastest_lap: 22.845,
            kart_num: 43,
            nickname: "Speedy Turtle",
            photo: "https://aisdulles.clubspeedtiming.com/CustomerPictures/8182382.jpg",
            position: 5,
            external_racer_id: "8182382",
            race_by: :laps,
            win_by: :laptime,
            race_id: 22445,
            racer_profile_id: 22375,
            location_id: 1,
            laps: [
              %KartVids.Races.Racer.Lap{
                lap_time: 23.199,
                amb_time: 4_301_841.293,
                lap_number: 1
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 22.845,
                amb_time: 4_301_864.138,
                lap_number: 2
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 23.92,
                amb_time: 4_301_888.058,
                lap_number: 3
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 24.267,
                amb_time: 4_301_912.325,
                lap_number: 4
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 22.973,
                amb_time: 4_301_935.298,
                lap_number: 5
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 23.081,
                amb_time: 4_301_958.379,
                lap_number: 6
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 22.985,
                amb_time: 4_301_981.364,
                lap_number: 7
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 23.217,
                amb_time: 4_302_004.581,
                lap_number: 8
              }
            ],
            inserted_at: ~N[2023-11-19 14:46:33],
            updated_at: ~N[2023-11-19 14:46:33]
          },
          %KartVids.Races.Racer{
            id: 110_079,
            average_lap: 23.056699999999996,
            fastest_lap: 22.587,
            kart_num: 42,
            nickname: "Han",
            photo: "https://aisdulles.clubspeedtiming.com/CustomerPictures/11233289.jpg",
            position: 4,
            external_racer_id: "11233289",
            race_by: :laps,
            win_by: :laptime,
            race_id: 22445,
            racer_profile_id: 19003,
            location_id: 1,
            laps: [
              %KartVids.Races.Racer.Lap{
                lap_time: 23.155,
                amb_time: 4_301_831.475,
                lap_number: 1
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 23.038,
                amb_time: 4_301_854.513,
                lap_number: 2
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 22.727,
                amb_time: 4_301_877.24,
                lap_number: 3
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 23.677,
                amb_time: 4_301_900.917,
                lap_number: 4
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 22.808,
                amb_time: 4_301_923.725,
                lap_number: 5
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 23.409,
                amb_time: 4_301_947.134,
                lap_number: 6
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 22.587,
                amb_time: 4_301_969.721,
                lap_number: 7
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 22.856,
                amb_time: 4_301_992.577,
                lap_number: 8
              }
            ],
            inserted_at: ~N[2023-11-19 14:46:33],
            updated_at: ~N[2023-11-19 14:46:33]
          },
          %KartVids.Races.Racer{
            id: 110_081,
            average_lap: 22.2331,
            fastest_lap: 21.766,
            kart_num: 45,
            nickname: "Owen",
            photo: "https://aisdulles.clubspeedtiming.com/CustomerPictures/11281138.jpg",
            position: 1,
            external_racer_id: "11281138",
            race_by: :laps,
            win_by: :laptime,
            race_id: 22445,
            racer_profile_id: 27506,
            location_id: 1,
            laps: [
              %KartVids.Races.Racer.Lap{
                lap_time: 22.499,
                amb_time: 4_301_843.665,
                lap_number: 1
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 21.85,
                amb_time: 4_301_865.515,
                lap_number: 2
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 22.424,
                amb_time: 4_301_887.939,
                lap_number: 3
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 22.583,
                amb_time: 4_301_910.522,
                lap_number: 4
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 21.973,
                amb_time: 4_301_932.495,
                lap_number: 5
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 21.766,
                amb_time: 4_301_954.261,
                lap_number: 6
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 22.094,
                amb_time: 4_301_976.355,
                lap_number: 7
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 22.144,
                amb_time: 4_301_998.499,
                lap_number: 8
              }
            ],
            inserted_at: ~N[2023-11-19 14:46:33],
            updated_at: ~N[2023-11-19 14:46:33]
          }
        ],
        inserted_at: ~N[2023-11-19 14:46:33],
        updated_at: ~N[2023-11-19 16:47:07]
      },
      %KartVids.Races.Race{
        id: 22446,
        name: "8 Lap",
        external_race_id: "212597",
        started_at: ~U[2023-11-19 14:48:00Z],
        ended_at: ~U[2023-11-19 14:52:00Z],
        league?: false,
        league_type: :none,
        location_id: 1,
        season_id: 2,
        racers: [
          %KartVids.Races.Racer{
            id: 110_086,
            average_lap: 26.055888888888887,
            fastest_lap: 23.405,
            kart_num: 49,
            nickname: "Austin",
            photo: "https://aisdulles.clubspeedtiming.com/CustomerPictures/11199007.jpg",
            position: 5,
            external_racer_id: "11199007",
            race_by: :laps,
            win_by: :laptime,
            race_id: 22446,
            racer_profile_id: 12532,
            location_id: 1,
            laps: [
              %KartVids.Races.Racer.Lap{
                lap_time: 24.543,
                amb_time: 4_302_194.313,
                lap_number: 1
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 23.405,
                amb_time: 4_302_217.718,
                lap_number: 2
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 30.56,
                amb_time: 4_302_248.278,
                lap_number: 3
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 25.402,
                amb_time: 4_302_273.68,
                lap_number: 4
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 25.194,
                amb_time: 4_302_298.874,
                lap_number: 5
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 31.258,
                amb_time: 4_302_330.132,
                lap_number: 6
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 25.055,
                amb_time: 4_302_355.187,
                lap_number: 7
              }
            ],
            inserted_at: ~N[2023-11-19 14:52:24],
            updated_at: ~N[2023-11-19 14:52:24]
          },
          %KartVids.Races.Racer{
            id: 110_083,
            average_lap: 22.772000000000002,
            fastest_lap: 21.692,
            kart_num: 31,
            nickname: "Matteo",
            photo: "https://aisdulles.clubspeedtiming.com/CustomerPictures/8192924.jpg",
            position: 3,
            external_racer_id: "8192924",
            race_by: :laps,
            win_by: :laptime,
            race_id: 22446,
            racer_profile_id: 21380,
            location_id: 1,
            laps: [
              %KartVids.Races.Racer.Lap{
                lap_time: 22.272,
                amb_time: 4_302_194.897,
                lap_number: 1
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 23.175,
                amb_time: 4_302_218.072,
                lap_number: 2
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 23.857,
                amb_time: 4_302_241.929,
                lap_number: 3
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 22.368,
                amb_time: 4_302_264.297,
                lap_number: 4
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 21.994,
                amb_time: 4_302_286.291,
                lap_number: 5
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 21.692,
                amb_time: 4_302_307.983,
                lap_number: 6
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 22.416,
                amb_time: 4_302_330.399,
                lap_number: 7
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 25.402,
                amb_time: 4_302_355.801,
                lap_number: 8
              }
            ],
            inserted_at: ~N[2023-11-19 14:52:24],
            updated_at: ~N[2023-11-19 14:52:24]
          },
          %KartVids.Races.Racer{
            id: 110_087,
            average_lap: 23.452499999999997,
            fastest_lap: 22.014,
            kart_num: 50,
            nickname: "Danny Jauregui",
            photo: "https://aisdulles.clubspeedtiming.com/CustomerPictures/11258317.jpg",
            position: 4,
            external_racer_id: "11258317",
            race_by: :laps,
            win_by: :laptime,
            race_id: 22446,
            racer_profile_id: 10249,
            location_id: 1,
            laps: [
              %KartVids.Races.Racer.Lap{
                lap_time: 25.744,
                amb_time: 4_302_174.937,
                lap_number: 1
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 22.014,
                amb_time: 4_302_196.951,
                lap_number: 2
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 22.205,
                amb_time: 4_302_219.156,
                lap_number: 3
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 23.614,
                amb_time: 4_302_242.77,
                lap_number: 4
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 22.587,
                amb_time: 4_302_265.357,
                lap_number: 5
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 22.482,
                amb_time: 4_302_287.839,
                lap_number: 6
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 22.267,
                amb_time: 4_302_310.106,
                lap_number: 7
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 22.124,
                amb_time: 4_302_332.23,
                lap_number: 8
              }
            ],
            inserted_at: ~N[2023-11-19 14:52:24],
            updated_at: ~N[2023-11-19 14:52:24]
          },
          %KartVids.Races.Racer{
            id: 110_085,
            average_lap: 21.80622222222222,
            fastest_lap: 21.586,
            kart_num: 47,
            nickname: "Sebastian Zieglar",
            photo: "https://aisdulles.clubspeedtiming.com/CustomerPictures/11213892.jpg",
            position: 2,
            external_racer_id: "11213892",
            race_by: :laps,
            win_by: :laptime,
            race_id: 22446,
            racer_profile_id: 199,
            location_id: 1,
            laps: [
              %KartVids.Races.Racer.Lap{
                lap_time: 21.925,
                amb_time: 4_302_202.773,
                lap_number: 1
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 21.759,
                amb_time: 4_302_224.532,
                lap_number: 2
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 21.586,
                amb_time: 4_302_246.118,
                lap_number: 3
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 21.794,
                amb_time: 4_302_267.912,
                lap_number: 4
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 21.692,
                amb_time: 4_302_289.604,
                lap_number: 5
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 21.962,
                amb_time: 4_302_311.566,
                lap_number: 6
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 21.688,
                amb_time: 4_302_333.254,
                lap_number: 7
              }
            ],
            inserted_at: ~N[2023-11-19 14:52:24],
            updated_at: ~N[2023-11-19 14:52:24]
          },
          %KartVids.Races.Racer{
            id: 110_084,
            average_lap: 21.8673,
            fastest_lap: 21.32,
            kart_num: 40,
            nickname: "Bentlee",
            photo: "https://aisdulles.clubspeedtiming.com/CustomerPictures/11187444.jpg",
            position: 1,
            external_racer_id: "11187444",
            race_by: :laps,
            win_by: :laptime,
            race_id: 22446,
            racer_profile_id: 8211,
            location_id: 1,
            laps: [
              %KartVids.Races.Racer.Lap{
                lap_time: 22.421,
                amb_time: 4_302_186.731,
                lap_number: 1
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 21.465,
                amb_time: 4_302_208.196,
                lap_number: 2
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 21.537,
                amb_time: 4_302_229.733,
                lap_number: 3
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 21.32,
                amb_time: 4_302_251.053,
                lap_number: 4
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 22.272,
                amb_time: 4_302_273.325,
                lap_number: 5
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 21.776,
                amb_time: 4_302_295.101,
                lap_number: 6
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 21.619,
                amb_time: 4_302_316.72,
                lap_number: 7
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 21.421,
                amb_time: 4_302_338.141,
                lap_number: 8
              }
            ],
            inserted_at: ~N[2023-11-19 14:52:24],
            updated_at: ~N[2023-11-19 14:52:24]
          }
        ],
        inserted_at: ~N[2023-11-19 14:52:24],
        updated_at: ~N[2023-11-19 16:47:11]
      },
      %KartVids.Races.Race{
        id: 22447,
        name: "8 Lap",
        external_race_id: "212598",
        started_at: ~U[2023-11-19 14:57:00Z],
        ended_at: ~U[2023-11-19 15:00:00Z],
        league?: false,
        league_type: :none,
        location_id: 1,
        season_id: 2,
        racers: [
          %KartVids.Races.Racer{
            id: 110_092,
            average_lap: 22.1236,
            fastest_lap: 21.78,
            kart_num: 55,
            nickname: "Arjun",
            photo: "https://aisdulles.clubspeedtiming.com/CustomerPictures/11183110.jpg",
            position: 5,
            external_racer_id: "11183110",
            race_by: :laps,
            win_by: :laptime,
            race_id: 22447,
            racer_profile_id: 144,
            location_id: 1,
            laps: [
              %KartVids.Races.Racer.Lap{
                lap_time: 22.232,
                amb_time: 4_302_711.814,
                lap_number: 1
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 21.964,
                amb_time: 4_302_733.778,
                lap_number: 2
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 21.893,
                amb_time: 4_302_755.671,
                lap_number: 3
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 21.78,
                amb_time: 4_302_777.451,
                lap_number: 4
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 21.842,
                amb_time: 4_302_799.293,
                lap_number: 5
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 21.869,
                amb_time: 4_302_821.162,
                lap_number: 6
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 23.324,
                amb_time: 4_302_844.486,
                lap_number: 7
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 21.868,
                amb_time: 4_302_866.354,
                lap_number: 8
              }
            ],
            inserted_at: ~N[2023-11-19 15:00:59],
            updated_at: ~N[2023-11-19 15:00:59]
          },
          %KartVids.Races.Racer{
            id: 110_089,
            average_lap: 21.2661,
            fastest_lap: 20.96,
            kart_num: 42,
            nickname: "Milo AE86",
            photo: "https://aisdulles.clubspeedtiming.com/CustomerPictures/8176814.jpg",
            position: 1,
            external_racer_id: "8176814",
            race_by: :laps,
            win_by: :laptime,
            race_id: 22447,
            racer_profile_id: 33829,
            location_id: 1,
            laps: [
              %KartVids.Races.Racer.Lap{
                lap_time: 21.26,
                amb_time: 4_302_717.878,
                lap_number: 1
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 21.024,
                amb_time: 4_302_738.902,
                lap_number: 2
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 21.074,
                amb_time: 4_302_759.976,
                lap_number: 3
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 20.96,
                amb_time: 4_302_780.936,
                lap_number: 4
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 21.097,
                amb_time: 4_302_802.033,
                lap_number: 5
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 21.031,
                amb_time: 4_302_823.064,
                lap_number: 6
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 21.928,
                amb_time: 4_302_844.992,
                lap_number: 7
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 21.767,
                amb_time: 4_302_866.759,
                lap_number: 8
              }
            ],
            inserted_at: ~N[2023-11-19 15:00:59],
            updated_at: ~N[2023-11-19 15:00:59]
          },
          %KartVids.Races.Racer{
            id: 110_091,
            average_lap: 21.470000000000006,
            fastest_lap: 21.357,
            kart_num: 52,
            nickname: "Jacob",
            photo: "https://aisdulles.clubspeedtiming.com/CustomerPictures/11234123.jpg",
            position: 4,
            external_racer_id: "11234123",
            race_by: :laps,
            win_by: :laptime,
            race_id: 22447,
            racer_profile_id: 15295,
            location_id: 1,
            laps: [
              %KartVids.Races.Racer.Lap{
                lap_time: 21.559,
                amb_time: 4_302_706.086,
                lap_number: 1
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 21.382,
                amb_time: 4_302_727.468,
                lap_number: 2
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 21.357,
                amb_time: 4_302_748.825,
                lap_number: 3
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 21.376,
                amb_time: 4_302_770.201,
                lap_number: 4
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 21.359,
                amb_time: 4_302_791.56,
                lap_number: 5
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 21.421,
                amb_time: 4_302_812.981,
                lap_number: 6
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 21.531,
                amb_time: 4_302_834.512,
                lap_number: 7
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 21.597,
                amb_time: 4_302_856.109,
                lap_number: 8
              }
            ],
            inserted_at: ~N[2023-11-19 15:00:59],
            updated_at: ~N[2023-11-19 15:00:59]
          },
          %KartVids.Races.Racer{
            id: 110_090,
            average_lap: 21.267599999999998,
            fastest_lap: 21.09,
            kart_num: 45,
            nickname: "Thomas_cruise Jr",
            photo: "https://aisdulles.clubspeedtiming.com/CustomerPictures/11240160.jpg",
            position: 2,
            external_racer_id: "11240160",
            race_by: :laps,
            win_by: :laptime,
            race_id: 22447,
            racer_profile_id: 1915,
            location_id: 1,
            laps: [
              %KartVids.Races.Racer.Lap{
                lap_time: 21.146,
                amb_time: 4_302_721.725,
                lap_number: 1
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 21.405,
                amb_time: 4_302_743.13,
                lap_number: 2
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 21.239,
                amb_time: 4_302_764.369,
                lap_number: 3
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 21.526,
                amb_time: 4_302_785.895,
                lap_number: 4
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 21.526,
                amb_time: 4_302_807.421,
                lap_number: 5
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 21.306,
                amb_time: 4_302_828.727,
                lap_number: 6
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 21.09,
                amb_time: 4_302_849.817,
                lap_number: 7
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 21.146,
                amb_time: 4_302_870.963,
                lap_number: 8
              }
            ],
            inserted_at: ~N[2023-11-19 15:00:59],
            updated_at: ~N[2023-11-19 15:00:59]
          },
          %KartVids.Races.Racer{
            id: 110_088,
            average_lap: 21.4525,
            fastest_lap: 21.317,
            kart_num: 32,
            nickname: "Lukas",
            photo: "https://aisdulles.clubspeedtiming.com/CustomerPictures/11212668.jpg",
            position: 3,
            external_racer_id: "11212668",
            race_by: :laps,
            win_by: :laptime,
            race_id: 22447,
            racer_profile_id: 132,
            location_id: 1,
            laps: [
              %KartVids.Races.Racer.Lap{
                lap_time: 21.418,
                amb_time: 4_302_714.271,
                lap_number: 1
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 21.343,
                amb_time: 4_302_735.614,
                lap_number: 2
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 21.522,
                amb_time: 4_302_757.136,
                lap_number: 3
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 21.356,
                amb_time: 4_302_778.492,
                lap_number: 4
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 21.49,
                amb_time: 4_302_799.982,
                lap_number: 5
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 21.535,
                amb_time: 4_302_821.517,
                lap_number: 6
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 21.708,
                amb_time: 4_302_843.225,
                lap_number: 7
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 21.317,
                amb_time: 4_302_864.542,
                lap_number: 8
              }
            ],
            inserted_at: ~N[2023-11-19 15:00:59],
            updated_at: ~N[2023-11-19 15:00:59]
          }
        ],
        inserted_at: ~N[2023-11-19 15:00:59],
        updated_at: ~N[2023-11-19 16:47:17]
      },
      %KartVids.Races.Race{
        id: 22448,
        name: "10 Lap JR Position",
        external_race_id: "212599",
        started_at: ~U[2023-11-19 15:17:00Z],
        ended_at: ~U[2023-11-19 15:22:00Z],
        league?: false,
        league_type: :none,
        location_id: 1,
        season_id: 2,
        racers: [
          %KartVids.Races.Racer{
            id: 110_094,
            average_lap: 25.757272727272724,
            fastest_lap: 24.533,
            kart_num: 42,
            nickname: "Lewis Hamilton Jr.",
            photo: "https://aisdulles.clubspeedtiming.com/CustomerPictures/11286132.jpg",
            position: 3,
            external_racer_id: "11286132",
            race_by: :laps,
            win_by: :position,
            race_id: 22448,
            racer_profile_id: 31622,
            location_id: 1,
            laps: [
              %KartVids.Races.Racer.Lap{
                lap_time: 26.565,
                amb_time: 4_303_955.941,
                lap_number: 1
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 24.533,
                amb_time: 4_303_980.474,
                lap_number: 2
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 26.561,
                amb_time: 4_304_007.035,
                lap_number: 3
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 26.069,
                amb_time: 4_304_033.104,
                lap_number: 4
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 25.652,
                amb_time: 4_304_058.756,
                lap_number: 5
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 25.348,
                amb_time: 4_304_084.104,
                lap_number: 6
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 24.686,
                amb_time: 4_304_108.79,
                lap_number: 7
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 25.127,
                amb_time: 4_304_133.917,
                lap_number: 8
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 25.659,
                amb_time: 4_304_159.576,
                lap_number: 9
              }
            ],
            inserted_at: ~N[2023-11-19 15:22:53],
            updated_at: ~N[2023-11-19 15:22:53]
          },
          %KartVids.Races.Racer{
            id: 110_093,
            average_lap: 24.436636363636364,
            fastest_lap: 23.275,
            kart_num: 40,
            nickname: "Jackson",
            photo: "https://aisdulles.clubspeedtiming.com/CustomerPictures/11241047.jpg",
            position: 2,
            external_racer_id: "11241047",
            race_by: :laps,
            win_by: :position,
            race_id: 22448,
            racer_profile_id: 760,
            location_id: 1,
            laps: [
              %KartVids.Races.Racer.Lap{
                lap_time: 26.174,
                amb_time: 4_303_954.584,
                lap_number: 1
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 23.291,
                amb_time: 4_303_977.875,
                lap_number: 2
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 24.447,
                amb_time: 4_304_002.322,
                lap_number: 3
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 23.454,
                amb_time: 4_304_025.776,
                lap_number: 4
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 23.358,
                amb_time: 4_304_049.134,
                lap_number: 5
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 23.275,
                amb_time: 4_304_072.409,
                lap_number: 6
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 24.488,
                amb_time: 4_304_096.897,
                lap_number: 7
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 23.65,
                amb_time: 4_304_120.547,
                lap_number: 8
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 24.318,
                amb_time: 4_304_144.865,
                lap_number: 9
              }
            ],
            inserted_at: ~N[2023-11-19 15:22:53],
            updated_at: ~N[2023-11-19 15:22:53]
          },
          %KartVids.Races.Racer{
            id: 110_095,
            average_lap: 28.524249999999995,
            fastest_lap: 22.573,
            kart_num: 48,
            nickname: "V1SNKRboi",
            photo: "https://aisdulles.clubspeedtiming.com/CustomerPictures/11191397.jpg",
            position: 1,
            external_racer_id: "11191397",
            race_by: :laps,
            win_by: :position,
            race_id: 22448,
            racer_profile_id: 27434,
            location_id: 1,
            laps: [
              %KartVids.Races.Racer.Lap{
                lap_time: 43.365,
                amb_time: 4_303_927.951,
                lap_number: 1
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 25.15,
                amb_time: 4_303_953.101,
                lap_number: 2
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 24.308,
                amb_time: 4_303_977.409,
                lap_number: 3
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 24.033,
                amb_time: 4_304_001.442,
                lap_number: 4
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 23.538,
                amb_time: 4_304_024.98,
                lap_number: 5
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 22.573,
                amb_time: 4_304_047.553,
                lap_number: 6
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 23.258,
                amb_time: 4_304_070.811,
                lap_number: 7
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 22.991,
                amb_time: 4_304_093.802,
                lap_number: 8
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 23.205,
                amb_time: 4_304_117.007,
                lap_number: 9
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 23.14,
                amb_time: 4_304_140.147,
                lap_number: 10
              }
            ],
            inserted_at: ~N[2023-11-19 15:22:53],
            updated_at: ~N[2023-11-19 15:22:53]
          }
        ],
        inserted_at: ~N[2023-11-19 15:22:53],
        updated_at: ~N[2023-11-19 16:47:24]
      },
      %KartVids.Races.Race{
        id: 22449,
        name: "10 Lap JR Position",
        external_race_id: "212600",
        started_at: ~U[2023-11-19 15:25:00Z],
        ended_at: ~U[2023-11-19 15:31:00Z],
        league?: false,
        league_type: :none,
        location_id: 1,
        season_id: 2,
        racers: [
          %KartVids.Races.Racer{
            id: 110_097,
            average_lap: 23.803083333333337,
            fastest_lap: 22.814,
            kart_num: 47,
            nickname: "Tigey",
            photo: "https://aisdulles.clubspeedtiming.com/CustomerPictures/11235108.jpg",
            position: 3,
            external_racer_id: "11235108",
            race_by: :laps,
            win_by: :position,
            race_id: 22449,
            racer_profile_id: 30420,
            location_id: 1,
            laps: [
              %KartVids.Races.Racer.Lap{
                lap_time: 25.294,
                amb_time: 4_304_483.851,
                lap_number: 1
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 23.347,
                amb_time: 4_304_507.198,
                lap_number: 2
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 23.332,
                amb_time: 4_304_530.53,
                lap_number: 3
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 23.315,
                amb_time: 4_304_553.845,
                lap_number: 4
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 23.091,
                amb_time: 4_304_576.936,
                lap_number: 5
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 23.594,
                amb_time: 4_304_600.53,
                lap_number: 6
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 23.405,
                amb_time: 4_304_623.935,
                lap_number: 7
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 23.836,
                amb_time: 4_304_647.771,
                lap_number: 8
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 23.021,
                amb_time: 4_304_670.792,
                lap_number: 9
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 22.814,
                amb_time: 4_304_693.606,
                lap_number: 10
              }
            ],
            inserted_at: ~N[2023-11-19 15:31:23],
            updated_at: ~N[2023-11-19 15:31:23]
          },
          %KartVids.Races.Racer{
            id: 110_096,
            average_lap: 23.201666666666668,
            fastest_lap: 22.333,
            kart_num: 43,
            nickname: "Austin",
            photo: "https://aisdulles.clubspeedtiming.com/CustomerPictures/11199007.jpg",
            position: 1,
            external_racer_id: "11199007",
            race_by: :laps,
            win_by: :position,
            race_id: 22449,
            racer_profile_id: 12532,
            location_id: 1,
            laps: [
              %KartVids.Races.Racer.Lap{
                lap_time: 24.127,
                amb_time: 4_304_481.777,
                lap_number: 1
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 22.955,
                amb_time: 4_304_504.732,
                lap_number: 2
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 23.772,
                amb_time: 4_304_528.504,
                lap_number: 3
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 22.853,
                amb_time: 4_304_551.357,
                lap_number: 4
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 22.897,
                amb_time: 4_304_574.254,
                lap_number: 5
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 22.819,
                amb_time: 4_304_597.073,
                lap_number: 6
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 22.942,
                amb_time: 4_304_620.015,
                lap_number: 7
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 22.333,
                amb_time: 4_304_642.348,
                lap_number: 8
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 22.885,
                amb_time: 4_304_665.233,
                lap_number: 9
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 22.583,
                amb_time: 4_304_687.816,
                lap_number: 10
              }
            ],
            inserted_at: ~N[2023-11-19 15:31:23],
            updated_at: ~N[2023-11-19 15:31:23]
          },
          %KartVids.Races.Racer{
            id: 110_099,
            average_lap: 23.11283333333333,
            fastest_lap: 22.372,
            kart_num: 52,
            nickname: "Han",
            photo: "https://aisdulles.clubspeedtiming.com/CustomerPictures/11233289.jpg",
            position: 2,
            external_racer_id: "11233289",
            race_by: :laps,
            win_by: :position,
            race_id: 22449,
            racer_profile_id: 19003,
            location_id: 1,
            laps: [
              %KartVids.Races.Racer.Lap{
                lap_time: 23.785,
                amb_time: 4_304_481.131,
                lap_number: 1
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 23.054,
                amb_time: 4_304_504.185,
                lap_number: 2
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 23.943,
                amb_time: 4_304_528.128,
                lap_number: 3
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 22.44,
                amb_time: 4_304_550.568,
                lap_number: 4
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 22.372,
                amb_time: 4_304_572.94,
                lap_number: 5
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 22.955,
                amb_time: 4_304_595.895,
                lap_number: 6
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 22.554,
                amb_time: 4_304_618.449,
                lap_number: 7
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 23.106,
                amb_time: 4_304_641.555,
                lap_number: 8
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 22.852,
                amb_time: 4_304_664.407,
                lap_number: 9
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 22.723,
                amb_time: 4_304_687.13,
                lap_number: 10
              }
            ],
            inserted_at: ~N[2023-11-19 15:31:23],
            updated_at: ~N[2023-11-19 15:31:23]
          },
          %KartVids.Races.Racer{
            id: 110_098,
            average_lap: 24.107749999999996,
            fastest_lap: 22.958,
            kart_num: 50,
            nickname: "Rudy Smith",
            photo: "https://aisdulles.clubspeedtiming.com/CustomerPictures/11238419.jpg",
            position: 4,
            external_racer_id: "11238419",
            race_by: :laps,
            win_by: :position,
            race_id: 22449,
            racer_profile_id: 31618,
            location_id: 1,
            laps: [
              %KartVids.Races.Racer.Lap{
                lap_time: 26.124,
                amb_time: 4_304_484.762,
                lap_number: 1
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 23.535,
                amb_time: 4_304_508.297,
                lap_number: 2
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 23.847,
                amb_time: 4_304_532.144,
                lap_number: 3
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 23.303,
                amb_time: 4_304_555.447,
                lap_number: 4
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 23.651,
                amb_time: 4_304_579.098,
                lap_number: 5
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 23.73,
                amb_time: 4_304_602.828,
                lap_number: 6
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 22.963,
                amb_time: 4_304_625.791,
                lap_number: 7
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 23.51,
                amb_time: 4_304_649.301,
                lap_number: 8
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 22.958,
                amb_time: 4_304_672.259,
                lap_number: 9
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 23.424,
                amb_time: 4_304_695.683,
                lap_number: 10
              }
            ],
            inserted_at: ~N[2023-11-19 15:31:23],
            updated_at: ~N[2023-11-19 15:31:23]
          }
        ],
        inserted_at: ~N[2023-11-19 15:31:23],
        updated_at: ~N[2023-11-19 16:47:28]
      },
      %KartVids.Races.Race{
        id: 22450,
        name: "10 Lap JR Position",
        external_race_id: "212601",
        started_at: ~U[2023-11-19 15:36:00Z],
        ended_at: ~U[2023-11-19 15:43:00Z],
        league?: false,
        league_type: :none,
        location_id: 1,
        season_id: 2,
        racers: [
          %KartVids.Races.Racer{
            id: 110_100,
            average_lap: 35.65890909090908,
            fastest_lap: 22.4,
            kart_num: 32,
            nickname: "Speedy Turtle",
            photo: "https://aisdulles.clubspeedtiming.com/CustomerPictures/8182382.jpg",
            position: 5,
            external_racer_id: "8182382",
            race_by: :laps,
            win_by: :position,
            race_id: 22450,
            racer_profile_id: 22375,
            location_id: 1,
            laps: [
              %KartVids.Races.Racer.Lap{
                lap_time: 25.388,
                amb_time: 4_305_087.124,
                lap_number: 1
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 153.284,
                amb_time: 4_305_240.408,
                lap_number: 2
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 25.111,
                amb_time: 4_305_265.519,
                lap_number: 3
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 23.227,
                amb_time: 4_305_288.746,
                lap_number: 4
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 22.4,
                amb_time: 4_305_311.146,
                lap_number: 5
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 23.191,
                amb_time: 4_305_334.337,
                lap_number: 6
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 22.755,
                amb_time: 4_305_357.092,
                lap_number: 7
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 23.55,
                amb_time: 4_305_380.642,
                lap_number: 8
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 22.566,
                amb_time: 4_305_403.208,
                lap_number: 9
              }
            ],
            inserted_at: ~N[2023-11-19 15:43:10],
            updated_at: ~N[2023-11-19 15:43:10]
          },
          %KartVids.Races.Racer{
            id: 110_102,
            average_lap: 35.21399999999999,
            fastest_lap: 22.397,
            kart_num: 42,
            nickname: "Paul",
            photo: "https://aisdulles.clubspeedtiming.com/CustomerPictures/11233287.jpg",
            position: 4,
            external_racer_id: "11233287",
            race_by: :laps,
            win_by: :position,
            race_id: 22450,
            racer_profile_id: 18997,
            location_id: 1,
            laps: [
              %KartVids.Races.Racer.Lap{
                lap_time: 23.664,
                amb_time: 4_305_083.51,
                lap_number: 1
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 155.888,
                amb_time: 4_305_239.398,
                lap_number: 2
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 24.867,
                amb_time: 4_305_264.265,
                lap_number: 3
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 22.675,
                amb_time: 4_305_286.94,
                lap_number: 4
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 22.692,
                amb_time: 4_305_309.632,
                lap_number: 5
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 22.737,
                amb_time: 4_305_332.369,
                lap_number: 6
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 22.687,
                amb_time: 4_305_355.056,
                lap_number: 7
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 22.397,
                amb_time: 4_305_377.453,
                lap_number: 8
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 22.419,
                amb_time: 4_305_399.872,
                lap_number: 9
              }
            ],
            inserted_at: ~N[2023-11-19 15:43:10],
            updated_at: ~N[2023-11-19 15:43:10]
          },
          %KartVids.Races.Racer{
            id: 110_103,
            average_lap: 38.64163636363636,
            fastest_lap: 21.53,
            kart_num: 45,
            nickname: "Bryson",
            photo: "https://aisdulles.clubspeedtiming.com/CustomerPictures/11274283.jpg",
            position: 1,
            external_racer_id: "11274283",
            race_by: :laps,
            win_by: :position,
            race_id: 22450,
            racer_profile_id: 21560,
            location_id: 1,
            laps: [
              %KartVids.Races.Racer.Lap{
                lap_time: 43.804,
                amb_time: 4_305_104.127,
                lap_number: 1
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 135.195,
                amb_time: 4_305_239.322,
                lap_number: 2
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 24.381,
                amb_time: 4_305_263.703,
                lap_number: 3
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 22.331,
                amb_time: 4_305_286.034,
                lap_number: 4
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 22.539,
                amb_time: 4_305_308.573,
                lap_number: 5
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 22.07,
                amb_time: 4_305_330.643,
                lap_number: 6
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 22.539,
                amb_time: 4_305_353.182,
                lap_number: 7
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 21.53,
                amb_time: 4_305_374.712,
                lap_number: 8
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 23.061,
                amb_time: 4_305_397.773,
                lap_number: 9
              }
            ],
            inserted_at: ~N[2023-11-19 15:43:10],
            updated_at: ~N[2023-11-19 15:43:10]
          },
          %KartVids.Races.Racer{
            id: 110_101,
            average_lap: 35.825636363636356,
            fastest_lap: 22.371,
            kart_num: 40,
            nickname: "Liam OBrien",
            photo: "https://aisdulles.clubspeedtiming.com/CustomerPictures/11207451.jpg",
            position: 3,
            external_racer_id: "11207451",
            race_by: :laps,
            win_by: :position,
            race_id: 22450,
            racer_profile_id: 31619,
            location_id: 1,
            laps: [
              %KartVids.Races.Racer.Lap{
                lap_time: 26.041,
                amb_time: 4_305_085.322,
                lap_number: 1
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 152.85,
                amb_time: 4_305_238.172,
                lap_number: 2
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 24.992,
                amb_time: 4_305_263.164,
                lap_number: 3
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 22.537,
                amb_time: 4_305_285.701,
                lap_number: 4
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 22.371,
                amb_time: 4_305_308.072,
                lap_number: 5
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 22.381,
                amb_time: 4_305_330.453,
                lap_number: 6
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 25.694,
                amb_time: 4_305_356.147,
                lap_number: 7
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 22.666,
                amb_time: 4_305_378.813,
                lap_number: 8
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 22.468,
                amb_time: 4_305_401.281,
                lap_number: 9
              }
            ],
            inserted_at: ~N[2023-11-19 15:43:10],
            updated_at: ~N[2023-11-19 15:43:10]
          },
          %KartVids.Races.Racer{
            id: 110_104,
            average_lap: 31.975833333333338,
            fastest_lap: 21.961,
            kart_num: 48,
            nickname: "Owen",
            photo: "https://aisdulles.clubspeedtiming.com/CustomerPictures/11281138.jpg",
            position: 2,
            external_racer_id: "11281138",
            race_by: :laps,
            win_by: :position,
            race_id: 22450,
            racer_profile_id: 27506,
            location_id: 1,
            laps: [
              %KartVids.Races.Racer.Lap{
                lap_time: 23.727,
                amb_time: 4_305_082.472,
                lap_number: 1
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 119.964,
                amb_time: 4_305_202.436,
                lap_number: 2
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 35.682,
                amb_time: 4_305_238.118,
                lap_number: 3
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 23.697,
                amb_time: 4_305_261.815,
                lap_number: 4
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 22.286,
                amb_time: 4_305_284.101,
                lap_number: 5
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 22.053,
                amb_time: 4_305_306.154,
                lap_number: 6
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 22.424,
                amb_time: 4_305_328.578,
                lap_number: 7
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 22.341,
                amb_time: 4_305_350.919,
                lap_number: 8
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 21.961,
                amb_time: 4_305_372.88,
                lap_number: 9
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 22.121,
                amb_time: 4_305_395.001,
                lap_number: 10
              }
            ],
            inserted_at: ~N[2023-11-19 15:43:11],
            updated_at: ~N[2023-11-19 15:43:11]
          }
        ],
        inserted_at: ~N[2023-11-19 15:43:10],
        updated_at: ~N[2023-11-19 16:47:32]
      },
      %KartVids.Races.Race{
        id: 22451,
        name: "10 Lap JR Position",
        external_race_id: "212602",
        started_at: ~U[2023-11-19 15:45:00Z],
        ended_at: ~U[2023-11-19 15:50:00Z],
        league?: false,
        league_type: :none,
        location_id: 1,
        season_id: 2,
        racers: [
          %KartVids.Races.Racer{
            id: 110_107,
            average_lap: 22.148833333333332,
            fastest_lap: 21.692,
            kart_num: 47,
            nickname: "Sebastian Zieglar",
            photo: "https://aisdulles.clubspeedtiming.com/CustomerPictures/11213892.jpg",
            position: 3,
            external_racer_id: "11213892",
            race_by: :laps,
            win_by: :position,
            race_id: 22451,
            racer_profile_id: 199,
            location_id: 1,
            laps: [
              %KartVids.Races.Racer.Lap{
                lap_time: 22.669,
                amb_time: 4_305_626.526,
                lap_number: 1
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 22.102,
                amb_time: 4_305_648.628,
                lap_number: 2
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 22.413,
                amb_time: 4_305_671.041,
                lap_number: 3
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 21.861,
                amb_time: 4_305_692.902,
                lap_number: 4
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 21.76,
                amb_time: 4_305_714.662,
                lap_number: 5
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 21.692,
                amb_time: 4_305_736.354,
                lap_number: 6
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 21.746,
                amb_time: 4_305_758.1,
                lap_number: 7
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 21.967,
                amb_time: 4_305_780.067,
                lap_number: 8
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 22.085,
                amb_time: 4_305_802.152,
                lap_number: 9
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 22.153,
                amb_time: 4_305_824.305,
                lap_number: 10
              }
            ],
            inserted_at: ~N[2023-11-19 15:50:17],
            updated_at: ~N[2023-11-19 15:50:17]
          },
          %KartVids.Races.Racer{
            id: 110_106,
            average_lap: 22.074833333333334,
            fastest_lap: 21.78,
            kart_num: 43,
            nickname: "Danny Jauregui",
            photo: "https://aisdulles.clubspeedtiming.com/CustomerPictures/11258317.jpg",
            position: 4,
            external_racer_id: "11258317",
            race_by: :laps,
            win_by: :position,
            race_id: 22451,
            racer_profile_id: 10249,
            location_id: 1,
            laps: [
              %KartVids.Races.Racer.Lap{
                lap_time: 22.482,
                amb_time: 4_305_626.162,
                lap_number: 1
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 22.129,
                amb_time: 4_305_648.291,
                lap_number: 2
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 22.211,
                amb_time: 4_305_670.502,
                lap_number: 3
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 21.87,
                amb_time: 4_305_692.372,
                lap_number: 4
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 21.891,
                amb_time: 4_305_714.263,
                lap_number: 5
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 21.785,
                amb_time: 4_305_736.048,
                lap_number: 6
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 21.791,
                amb_time: 4_305_757.839,
                lap_number: 7
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 21.863,
                amb_time: 4_305_779.702,
                lap_number: 8
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 22.132,
                amb_time: 4_305_801.834,
                lap_number: 9
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 21.78,
                amb_time: 4_305_823.614,
                lap_number: 10
              }
            ],
            inserted_at: ~N[2023-11-19 15:50:17],
            updated_at: ~N[2023-11-19 15:50:17]
          },
          %KartVids.Races.Racer{
            id: 110_108,
            average_lap: 22.492416666666667,
            fastest_lap: 21.919,
            kart_num: 50,
            nickname: "Matteo",
            photo: "https://aisdulles.clubspeedtiming.com/CustomerPictures/8192924.jpg",
            position: 5,
            external_racer_id: "8192924",
            race_by: :laps,
            win_by: :position,
            race_id: 22451,
            racer_profile_id: 21380,
            location_id: 1,
            laps: [
              %KartVids.Races.Racer.Lap{
                lap_time: 22.983,
                amb_time: 4_305_627.577,
                lap_number: 1
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 21.953,
                amb_time: 4_305_649.53,
                lap_number: 2
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 22.297,
                amb_time: 4_305_671.827,
                lap_number: 3
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 22.252,
                amb_time: 4_305_694.079,
                lap_number: 4
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 23.207,
                amb_time: 4_305_717.286,
                lap_number: 5
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 22.385,
                amb_time: 4_305_739.671,
                lap_number: 6
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 21.919,
                amb_time: 4_305_761.59,
                lap_number: 7
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 22.093,
                amb_time: 4_305_783.683,
                lap_number: 8
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 22.623,
                amb_time: 4_305_806.306,
                lap_number: 9
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 22.231,
                amb_time: 4_305_828.537,
                lap_number: 10
              }
            ],
            inserted_at: ~N[2023-11-19 15:50:17],
            updated_at: ~N[2023-11-19 15:50:17]
          },
          %KartVids.Races.Racer{
            id: 110_105,
            average_lap: 22.02258333333333,
            fastest_lap: 21.434,
            kart_num: 31,
            nickname: "Emmitt",
            photo: "https://aisdulles.clubspeedtiming.com/CustomerPictures/1519776.jpg",
            position: 1,
            external_racer_id: "1519776",
            race_by: :laps,
            win_by: :position,
            race_id: 22451,
            racer_profile_id: 125,
            location_id: 1,
            laps: [
              %KartVids.Races.Racer.Lap{
                lap_time: 22.828,
                amb_time: 4_305_625.154,
                lap_number: 1
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 21.895,
                amb_time: 4_305_647.049,
                lap_number: 2
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 22.863,
                amb_time: 4_305_669.912,
                lap_number: 3
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 21.434,
                amb_time: 4_305_691.346,
                lap_number: 4
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 21.498,
                amb_time: 4_305_712.844,
                lap_number: 5
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 21.471,
                amb_time: 4_305_734.315,
                lap_number: 6
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 21.492,
                amb_time: 4_305_755.807,
                lap_number: 7
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 21.753,
                amb_time: 4_305_777.56,
                lap_number: 8
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 21.743,
                amb_time: 4_305_799.303,
                lap_number: 9
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 21.638,
                amb_time: 4_305_820.941,
                lap_number: 10
              }
            ],
            inserted_at: ~N[2023-11-19 15:50:17],
            updated_at: ~N[2023-11-19 15:50:17]
          },
          %KartVids.Races.Racer{
            id: 110_109,
            average_lap: 21.919749999999997,
            fastest_lap: 21.498,
            kart_num: 52,
            nickname: "Arjun",
            photo: "https://aisdulles.clubspeedtiming.com/CustomerPictures/11183110.jpg",
            position: 2,
            external_racer_id: "11183110",
            race_by: :laps,
            win_by: :position,
            race_id: 22451,
            racer_profile_id: 144,
            location_id: 1,
            laps: [
              %KartVids.Races.Racer.Lap{
                lap_time: 22.71,
                amb_time: 4_305_625.612,
                lap_number: 1
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 21.667,
                amb_time: 4_305_647.279,
                lap_number: 2
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 21.978,
                amb_time: 4_305_669.257,
                lap_number: 3
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 21.579,
                amb_time: 4_305_690.836,
                lap_number: 4
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 21.542,
                amb_time: 4_305_712.378,
                lap_number: 5
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 21.498,
                amb_time: 4_305_733.876,
                lap_number: 6
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 21.632,
                amb_time: 4_305_755.508,
                lap_number: 7
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 21.735,
                amb_time: 4_305_777.243,
                lap_number: 8
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 21.648,
                amb_time: 4_305_798.891,
                lap_number: 9
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 21.628,
                amb_time: 4_305_820.519,
                lap_number: 10
              }
            ],
            inserted_at: ~N[2023-11-19 15:50:17],
            updated_at: ~N[2023-11-19 15:50:17]
          }
        ],
        inserted_at: ~N[2023-11-19 15:50:17],
        updated_at: ~N[2023-11-19 16:47:35]
      },
      %KartVids.Races.Race{
        id: 22452,
        name: "10 Lap JR Position",
        external_race_id: "212603",
        started_at: ~U[2023-11-19 15:54:00Z],
        ended_at: ~U[2023-11-19 15:58:00Z],
        league?: false,
        league_type: :none,
        location_id: 1,
        season_id: 2,
        racers: [
          %KartVids.Races.Racer{
            id: 110_114,
            average_lap: 21.969749999999994,
            fastest_lap: 21.02,
            kart_num: 48,
            nickname: "Bentlee",
            photo: "https://aisdulles.clubspeedtiming.com/CustomerPictures/11187444.jpg",
            position: 2,
            external_racer_id: "11187444",
            race_by: :laps,
            win_by: :position,
            race_id: 22452,
            racer_profile_id: 8211,
            location_id: 1,
            laps: [
              %KartVids.Races.Racer.Lap{
                lap_time: 23.376,
                amb_time: 4_306_136.205,
                lap_number: 1
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 21.531,
                amb_time: 4_306_157.736,
                lap_number: 2
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 21.201,
                amb_time: 4_306_178.937,
                lap_number: 3
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 21.246,
                amb_time: 4_306_200.183,
                lap_number: 4
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 21.02,
                amb_time: 4_306_221.203,
                lap_number: 5
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 21.749,
                amb_time: 4_306_242.952,
                lap_number: 6
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 21.587,
                amb_time: 4_306_264.539,
                lap_number: 7
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 21.654,
                amb_time: 4_306_286.193,
                lap_number: 8
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 21.67,
                amb_time: 4_306_307.863,
                lap_number: 9
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 21.851,
                amb_time: 4_306_329.714,
                lap_number: 10
              }
            ],
            inserted_at: ~N[2023-11-19 15:58:42],
            updated_at: ~N[2023-11-19 15:58:42]
          },
          %KartVids.Races.Racer{
            id: 110_112,
            average_lap: 22.169,
            fastest_lap: 20.98,
            kart_num: 42,
            nickname: "Milo AE86",
            photo: "https://aisdulles.clubspeedtiming.com/CustomerPictures/8176814.jpg",
            position: 1,
            external_racer_id: "8176814",
            race_by: :laps,
            win_by: :position,
            race_id: 22452,
            racer_profile_id: 33829,
            location_id: 1,
            laps: [
              %KartVids.Races.Racer.Lap{
                lap_time: 23.891,
                amb_time: 4_306_134.819,
                lap_number: 1
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 20.98,
                amb_time: 4_306_155.799,
                lap_number: 2
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 21.242,
                amb_time: 4_306_177.041,
                lap_number: 3
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 21.563,
                amb_time: 4_306_198.604,
                lap_number: 4
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 21.72,
                amb_time: 4_306_220.324,
                lap_number: 5
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 22.396,
                amb_time: 4_306_242.72,
                lap_number: 6
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 21.376,
                amb_time: 4_306_264.096,
                lap_number: 7
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 21.833,
                amb_time: 4_306_285.929,
                lap_number: 8
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 21.719,
                amb_time: 4_306_307.648,
                lap_number: 9
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 21.526,
                amb_time: 4_306_329.174,
                lap_number: 10
              }
            ],
            inserted_at: ~N[2023-11-19 15:58:42],
            updated_at: ~N[2023-11-19 15:58:42]
          },
          %KartVids.Races.Racer{
            id: 110_110,
            average_lap: 22.661833333333334,
            fastest_lap: 21.509,
            kart_num: 32,
            nickname: "Lukas",
            photo: "https://aisdulles.clubspeedtiming.com/CustomerPictures/11212668.jpg",
            position: 4,
            external_racer_id: "11212668",
            race_by: :laps,
            win_by: :position,
            race_id: 22452,
            racer_profile_id: 132,
            location_id: 1,
            laps: [
              %KartVids.Races.Racer.Lap{
                lap_time: 25.134,
                amb_time: 4_306_137.155,
                lap_number: 1
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 22.421,
                amb_time: 4_306_159.576,
                lap_number: 2
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 21.828,
                amb_time: 4_306_181.404,
                lap_number: 3
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 21.773,
                amb_time: 4_306_203.177,
                lap_number: 4
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 21.685,
                amb_time: 4_306_224.862,
                lap_number: 5
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 21.723,
                amb_time: 4_306_246.585,
                lap_number: 6
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 21.7,
                amb_time: 4_306_268.285,
                lap_number: 7
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 21.509,
                amb_time: 4_306_289.794,
                lap_number: 8
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 22.003,
                amb_time: 4_306_311.797,
                lap_number: 9
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 21.898,
                amb_time: 4_306_333.695,
                lap_number: 10
              }
            ],
            inserted_at: ~N[2023-11-19 15:58:42],
            updated_at: ~N[2023-11-19 15:58:42]
          },
          %KartVids.Races.Racer{
            id: 110_113,
            average_lap: 22.02158333333333,
            fastest_lap: 21.357,
            kart_num: 45,
            nickname: "Jacob",
            photo: "https://aisdulles.clubspeedtiming.com/CustomerPictures/11234123.jpg",
            position: 3,
            external_racer_id: "11234123",
            race_by: :laps,
            win_by: :position,
            race_id: 22452,
            racer_profile_id: 15295,
            location_id: 1,
            laps: [
              %KartVids.Races.Racer.Lap{
                lap_time: 23.317,
                amb_time: 4_306_133.832,
                lap_number: 1
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 21.368,
                amb_time: 4_306_155.2,
                lap_number: 2
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 21.523,
                amb_time: 4_306_176.723,
                lap_number: 3
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 21.571,
                amb_time: 4_306_198.294,
                lap_number: 4
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 21.782,
                amb_time: 4_306_220.076,
                lap_number: 5
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 21.854,
                amb_time: 4_306_241.93,
                lap_number: 6
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 21.728,
                amb_time: 4_306_263.658,
                lap_number: 7
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 21.554,
                amb_time: 4_306_285.212,
                lap_number: 8
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 21.571,
                amb_time: 4_306_306.783,
                lap_number: 9
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 21.357,
                amb_time: 4_306_328.14,
                lap_number: 10
              }
            ],
            inserted_at: ~N[2023-11-19 15:58:42],
            updated_at: ~N[2023-11-19 15:58:42]
          },
          %KartVids.Races.Racer{
            id: 110_111,
            average_lap: 22.650833333333335,
            fastest_lap: 21.544,
            kart_num: 40,
            nickname: "Thomas_cruise Jr",
            photo: "https://aisdulles.clubspeedtiming.com/CustomerPictures/11240160.jpg",
            position: 5,
            external_racer_id: "11240160",
            race_by: :laps,
            win_by: :position,
            race_id: 22452,
            racer_profile_id: 1915,
            location_id: 1,
            laps: [
              %KartVids.Races.Racer.Lap{
                lap_time: 25.122,
                amb_time: 4_306_137.009,
                lap_number: 1
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 22.153,
                amb_time: 4_306_159.162,
                lap_number: 2
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 21.795,
                amb_time: 4_306_180.957,
                lap_number: 3
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 21.809,
                amb_time: 4_306_202.766,
                lap_number: 4
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 21.844,
                amb_time: 4_306_224.61,
                lap_number: 5
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 21.637,
                amb_time: 4_306_246.247,
                lap_number: 6
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 21.66,
                amb_time: 4_306_267.907,
                lap_number: 7
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 21.544,
                amb_time: 4_306_289.451,
                lap_number: 8
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 21.993,
                amb_time: 4_306_311.444,
                lap_number: 9
              },
              %KartVids.Races.Racer.Lap{
                lap_time: 22.009,
                amb_time: 4_306_333.453,
                lap_number: 10
              }
            ],
            inserted_at: ~N[2023-11-19 15:58:42],
            updated_at: ~N[2023-11-19 15:58:42]
          }
        ],
        inserted_at: ~N[2023-11-19 15:58:42],
        updated_at: ~N[2023-11-19 16:47:38]
      }
    ]
  end
end
