const db = require('../../Config/config');

const controller = {};

controller.createProcedure = (req, res) => {
  const { type, data } = req.body;

  const sql = 'INSERT INTO app_info (type, data) VALUES (?, ?)';

  db.query(sql, [type, data], (err, result) => {
    if (err) {
      console.error('Error executing query:', err);
      return res.status(500).json({ error: 'Database error' });
    }

    res.status(200).json({ message: 'Procedure created successfully', procedureId: result.insertId });
  });
};

controller.getProcedure = (req, res) => {
  const procedureId = req.params.id;

  const sql = 'SELECT * FROM app_info WHERE id = ?';

  db.query(sql, [procedureId], (err, result) => {
    if (err) {
      console.error('Error executing query:', err);
      return res.status(500).json({ error: 'Database error' });
    }

    if (result.length === 0) {
      return res.status(404).json({ error: 'Procedure not found' });
    }

    res.status(200).json(result[0]);
  });
};

controller.updateProcedure = (req, res) => {
  const procedureId = req.params.id;

  const { type, data } = req.body;

  const sql = 'UPDATE app_info SET type = ?, data = ? WHERE id = ?';

  db.query(sql, [type, data, procedureId], (err, result) => {
    if (err) {
      console.error('Error executing query:', err);
      return res.status(500).json({ error: 'Database error' });
    }

    if (result.affectedRows === 0) {
      return res.status(404).json({ error: 'Procedure not found or no changes made' });
    }

    res.status(200).json({ message: 'Procedure updated successfully' });
  });
};

controller.deleteProcedure = (req, res) => {
  const procedureId = req.params.id;

  const sql = 'DELETE FROM app_info WHERE id = ?';

  db.query(sql, [procedureId], (err, result) => {
    if (err) {
      console.error('Error executing query:', err);
      return res.status(500).json({ error: 'Database error' });
    }

    if (result.affectedRows === 0) {
      return res.status(404).json({ error: 'no data affected' });
    }

    res.status(200).json({ message: 'Procedure deleted successfully' });
  });
};

controller.getAllRows = (req, res) => {
  const sql = 'SELECT * FROM app_info';

  db.query(sql, (err, results) => {
    if (err) {
      console.error('Error executing query:', err);
      return res.status(500).json({ error: 'Database error' });
    }

    res.status(200).json(results);
  });
};

controller.getLatest = (req, res) => {
  const type = req.params.type;
  const sql = 'SELECT * FROM app_info WHERE type = ? LIMIT 1'
  console.log('type: ', type);

  db.query(sql, [type], (err, results) => {
    if (err) {
      console.error('Error executing query:', err);
      return res.status(500).json({error: 'Database error'});
    }

    res.status(200).json(results);
  })
}

module.exports = controller;
