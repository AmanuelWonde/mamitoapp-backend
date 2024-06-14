const express = require('express');
const router = express.Router();
const controller = require('../../Controllers/appInfo');

router.post('/', controller.createProcedure);

router.get('/get-all', controller.getAllRows);

router.get('/latest/:type', controller.getLatest);

router.get('/:id', controller.getProcedure);

router.put('/:id', controller.updateProcedure);

router.delete('/:id', controller.deleteProcedure);

module.exports = router;
