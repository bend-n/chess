extends Button


class TestChess:
	extends Resource

	const LOG_FILE = "user://tests.log"

	func test_algebraic_conversion():
		for k in Chess.SQUARE_MAP:
			assert(Chess.algebraic(Chess.SQUARE_MAP[k]) == k)

	func test_perft():
		var perfts = [
			{fen = "r3k2r/p1ppqpb1/bn2pnp1/3PN3/1p2P3/2N2Q1p/PPPBBPPP/R3K2R w KQkq - 0 1", depth = 3},
			{fen = "8/PPP4k/8/8/8/8/4Kppp/8 w - - 0 1", depth = 4, nodes = 84923},
			{fen = "8/2p5/3p4/KP5r/1R3p1k/8/4P1P1/8 w - - 0 1", depth = 4},
			{fen = "rnbqkbnr/p3pppp/2p5/1pPp4/3P4/8/PP2PPPP/RNBQKBNR w KQkq b6 0 4", depth = 3},
		]
		for perft in perfts:
			var c = Chess.new(perft.fen)
			var _nodes = c.perft(perft.depth)

	func test_single_square_move_generation():
		var positions = [
			{
				fen = "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1",
				square = "e2",
				moves = ["e3", "e4"],
			},
			{
				fen = "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1",
				square = "e9",
				moves = [],
			},  #invalid square
			{
				fen = "rnbqk1nr/pppp1ppp/4p3/8/1b1P4/2N5/PPP1PPPP/R1BQKBNR w KQkq - 2 3",
				square = "c3",
				moves = [],
			},  # pinned piece
			{
				fen = "8/k7/8/8/8/8/7p/K7 b - - 0 1",
				square = "h2",
				moves = ["h1=Q+", "h1=R+", "h1=B", "h1=N"],
			},  # promotion
			{
				fen = "r1bq1rk1/1pp2ppp/p1np1n2/2b1p3/2B1P3/2NP1N2/PPPBQPPP/R3K2R w KQ - 0 8",
				square = "e1",
				moves = ["Kf1", "Kd1", "O-O", "O-O-O"],
			},  # castling
			{
				fen = "r1bq1rk1/1pp2ppp/p1np1n2/2b1p3/2B1P3/2NP1N2/PPPBQPPP/R3K2R w - - 0 8",
				square = "e1",
				moves = ["Kf1", "Kd1"],
			},  # no castling
			{
				fen = "8/7K/8/8/1R6/k7/1R1p4/8 b - - 0 1",
				square = "a3",
				moves = [],
			},  # trapped king
			{
				fen = "8/7K/8/8/1R6/k7/1R1p4/8 b - - 0 1",
				square = "d2",
				verbose = true,
				moves = [
					{
						color = "b",
						from = "d2",
						to = "d1",
						flags = "np",
						piece = "p",
						promotion = "q",
						san = "d1=Q",
					},
					{
						color = "b",
						from = "d2",
						to = "d1",
						flags = "np",
						piece = "p",
						promotion = "r",
						san = "d1=R",
					},
					{
						color = "b",
						from = "d2",
						to = "d1",
						flags = "np",
						piece = "p",
						promotion = "b",
						san = "d1=B",
					},
					{
						color = "b",
						from = "d2",
						to = "d1",
						flags = "np",
						piece = "p",
						promotion = "n",
						san = "d1=N",
					},
				],
			},  # verbose
			{
				fen = "rnbqk2r/ppp1pp1p/5n1b/3p2pQ/1P2P3/B1N5/P1PP1PPP/R3KBNR b KQkq - 3 5",
				square = "f1",
				verbose = true,
				moves = [],
			},
			{
				fen = "rnbqkbnr/ppp2ppp/3pp3/8/4P3/2N5/PPPP1PPP/R1BQKBNR w KQkq - 0 3",
				square = "g1",
				moves = ["Nge2", "Nf3", "Nh3"]
			}  # disambiguation
		]
		for position in positions:
			var chess = Chess.new(position.fen)
			var cfg = {
				square = position.square,
				verbose = position.verbose if "verbose" in position else false,
			}
			var moves = chess.moves(cfg)
			if "verbose" in position && position.verbose:
				for i in range(len(moves)):
					assert(
						moves[i].hash() == position.moves[i].hash(),
						"%s should have been %s" % [moves[i], position.moves[i]]
					)
			else:
				assert(moves == position.moves, "%s should have been %s" % [moves, position.moves])

	func test_checkmates():
		var checkmates = [
			"8/5r2/4K1q1/4p3/3k4/8/8/8 w - - 0 7",
			"4r2r/p6p/1pnN2p1/kQp5/3pPq2/3P4/PPP3PP/R5K1 b - - 0 2",
			"r3k2r/ppp2p1p/2n1p1p1/8/2B2P1q/2NPb1n1/PP4PP/R2Q3K w kq - 0 8",
			"8/6R1/pp1r3p/6p1/P3R1Pk/1P4P1/7K/8 b - - 0 4",
		]

		for fen in checkmates:
			var chess = Chess.new(fen)
			assert(chess.in_checkmate() == true)
			assert(chess.in_draw() == false)

		var no_checkmates = [
			"rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1",
			"1R6/8/8/8/8/8/7R/k6K b - - 0 1",  # stalemate
		]

		for fen in no_checkmates:
			var chess = Chess.new(fen)
			assert(chess.in_checkmate() == false)

	func test_stalemates():
		var stalemates = [
			"1R6/8/8/8/8/8/7R/k6K b - - 0 1",
			"8/8/5k2/p4p1p/P4K1P/1r6/8/8 w - - 0 2",
		]
		for fen in stalemates:
			var chess = Chess.new(fen)
			assert(chess.in_stalemate() == true)
			assert(chess.in_draw() == true)

	func test_insufficient_material():
		var drawn = [
			"8/8/8/8/8/8/8/k6K w - - 0 1",
			"8/2N5/8/8/8/8/8/k6K w - - 0 1",
			"8/2b5/8/8/8/8/8/k6K w - - 0 1",
			"8/b7/3B4/8/8/8/8/k6K w - - 0 1",
			"8/b1B1b1B1/1b1B1b1B/8/8/8/8/1k5K w - - 0 1",
		]

		var not_drawn = [
			"rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1",
			"8/2p5/8/8/8/8/8/k6K w - - 0 1",
			"8/b7/B7/8/8/8/8/k6K w - - 0 1",
			"8/bB2b1B1/1b1B1b1B/8/8/8/8/1k5K w - - 0 1",
		]
		for fen in drawn:
			var chess = Chess.new(fen)
			assert(chess.insufficient_material() == true)
			assert(chess.in_draw() == true)
		for fen in not_drawn:
			var chess = Chess.new(fen)
			assert(chess.insufficient_material() == false)
			assert(chess.in_draw() == false)

	func test_threefold_repetition():
		var positions = [
			{
				fen = "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1",
				moves = "Nf3 Nf6 Ng1 Ng8 Nf3 Nf6 Ng1 Ng8",
			},
			# Fischer - Petrosian, Buenos Aires, 1971
			{
				fen = "8/pp3p1k/2p2q1p/3r1P2/5R2/7P/P1P1QP2/7K b - - 2 30",
				moves = "Qe5 Qh5 Qf6 Qe2 Re5 Qd3 Rd5 Qe2",
			},
		]

		for position in positions:
			var chess = Chess.new(position.fen)
			for move in position.moves.split(" "):
				assert(chess.in_threefold_repetition() == false)
				chess.move(move)
			assert(chess.in_threefold_repetition() == true)
			assert(chess.in_draw() == true)

	func test_move_generation():
		var positions = [
			{
				fen = "r6k/8/8/8/8/8/8/7K b - - 0 1",
				moves = """Ra7 Ra6 Ra5 Ra4 Ra3 Ra2 Ra1 Rb8 Rc8 Rd8 Re8 Rf8 Rg8 Kh7 Kg8 Kg7"""
			},
			{
				fen = "7k/3R4/3p2Q1/6Q1/2N1N3/8/8/3R3K w - - 0 1",
				moves = """Rd8# Re7 Rf7 Rg7 Rh7# R7xd6 Rc7 Rb7 Ra7 Qf7 Qe8# Qg7# Qg8# Qh7# Q6h6# Q6h5# Q6f5 Q6f6# Qe6 Qxd6 Q5f6# Qe7 Qd8# Q5h6# Q5h5# Qh4# Qg4 Qg3 Qg2 Qg1 Qf4 Qe3 Qd2 Qc1 Q5f5 Qe5+ Qd5 Qc5 Qb5 Qa5 Na5 Nb6 Ncxd6 Ne5 Ne3 Ncd2 Nb2 Na3 Nc5 Nexd6 Nf6 Ng3 Nf2 Ned2 Nc3 Rd2 Rd3 Rd4 Rd5 R1xd6 Re1 Rf1 Rg1 Rc1 Rb1 Ra1 Kg2 Kh2 Kg1""",
			},
			{
				fen = "1r3k2/P1P5/8/8/8/8/8/R3K2R w KQ - 0 1",
				moves = """a8=Q a8=R a8=B a8=N axb8=Q+ axb8=R+ axb8=B axb8=N c8=Q+ c8=R+ c8=B c8=N cxb8=Q+ cxb8=R+ cxb8=B cxb8=N Ra2 Ra3 Ra4 Ra5 Ra6 Rb1 Rc1 Rd1 Kd2 Ke2 Kf2 Kf1 Kd1 Rh2 Rh3 Rh4 Rh5 Rh6 Rh7 Rh8+ Rg1 Rf1+ O-O+ O-O-O""",
			},
			{
				fen = "5rk1/8/8/8/8/8/2p5/R3K2R w KQ - 0 1",
				moves = """Ra2 Ra3 Ra4 Ra5 Ra6 Ra7 Ra8 Rb1 Rc1 Rd1 Kd2 Ke2 Rh2 Rh3 Rh4 Rh5 Rh6 Rh7 Rh8+ Rg1+ Rf1""",
			},
			{
				fen = "5rk1/8/8/8/8/8/2p5/R3K2R b KQ - 0 1",
				moves = """Rf7 Rf6 Rf5 Rf4 Rf3 Rf2 Rf1+ Re8+ Rd8 Rc8 Rb8 Ra8 Kg7 Kf7 c1=Q+ c1=R+ c1=B c1=N""",
			},
			{
				fen = "r3k2r/p2pqpb1/1n2pnp1/2pPN3/1p2P3/2N2Q1p/PPPB1PPP/R3K2R w KQkq c6 0 2",
				moves = """gxh3 Qxf6 Qxh3 Nxd7 Nxf7 Nxg6 dxc6 dxe6 Rg1 Rf1 Ke2 Kf1 Kd1 Rb1 Rc1 Rd1 g3 g4 Be3 Bf4 Bg5 Bh6 Bc1 b3 a3 a4 Qf4 Qf5 Qg4 Qh5 Qg3 Qe2 Qd1 Qe3 Qd3 Na4 Nb5 Ne2 Nd1 Nb1 Nc6 Ng4 Nd3 Nc4 d6 O-O O-O-O""",
			},
			{
				fen = "k7/8/K7/8/3n3n/5R2/3n4/8 b - - 0 1",
				moves = """N2xf3 Nhxf3 Nd4xf3 N2b3 Nc4 Ne4 Nf1 Nb1 Nhf5 Ng6 Ng2 Nb5 Nc6 Ne6 Ndf5 Ne2 Nc2 N4b3 Kb8""",
			},
		]

		for position in positions:
			var chess = Chess.new(position.fen)
			assert(Array(chess.moves()).sort() == Array(position.moves.split(" ")).sort())

	func test_random_moves():
		for _i in range(5):  # 5 random games
			var c = Chess.new()
			while c.game_over() == false:
				var possible_moves = c.moves()
				var mov = possible_moves[randi() % len(possible_moves)]
				c.move(mov)
			Log.file(LOG_FILE, c.pgn() + "\n--------------------\n")

	func _init():
		SaveLoad.save_string("user://tests.log", "")  #overwrite last logs
		Log.file(LOG_FILE, "starting algebraic conversion tests")
		test_algebraic_conversion()
		Log.file(LOG_FILE, "starting perft tests")
		test_perft()
		Log.file(LOG_FILE, "starting move generation tests")
		test_single_square_move_generation()
		Log.file(LOG_FILE, "starting checkmate tests")
		test_checkmates()
		Log.file(LOG_FILE, "starting stalemate tests")
		test_stalemates()
		Log.file(LOG_FILE, "starting insufficient material tests")
		test_insufficient_material()
		Log.file(LOG_FILE, "starting threefold repetition tests")
		test_threefold_repetition()
		Log.file(LOG_FILE, "starting move generation tests")
		test_move_generation()
		Log.file(LOG_FILE, "starting random moves tests")
		test_random_moves()  # crash testing
		Log.file(LOG_FILE, "all tests passed")


func _pressed():
	TestChess.new()
	Log.debug("all tests passed")
